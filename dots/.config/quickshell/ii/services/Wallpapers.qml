import qs.modules.common
import qs.modules.common.models
import qs.modules.common.functions
import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
pragma Singleton
pragma ComponentBehavior: Bound

/**
 * Provides a list of wallpapers and an "apply" action that calls the existing
 * switchwall.sh script. Pretty much a limited file browsing service.
 */
Singleton {
    id: root

    property string thumbgenScriptPath: `${FileUtils.trimFileProtocol(Directories.scriptPath)}/thumbnails/thumbgen-venv.sh`
    property string generateThumbnailsMagickScriptPath: `${FileUtils.trimFileProtocol(Directories.scriptPath)}/thumbnails/generate-thumbnails-magick.sh`
    property string extractColorsScriptPath: FileUtils.trimFileProtocol(Directories.extractColorsScriptPath)
    property alias directory: folderModel.folder
    readonly property string effectiveDirectory: FileUtils.trimFileProtocol(folderModel.folder.toString())
    property url defaultFolder: {
        if (Config.ready && Config.options.wallpaperSelector.useCustomDefaultPath && Config.options.wallpaperSelector.customDefaultPath) {
            return Qt.resolvedUrl("file://" + Config.options.wallpaperSelector.customDefaultPath);
        }
        return Qt.resolvedUrl(`${Directories.pictures}/Wallpapers`);
    }
    property alias folderModel: folderModel // Expose for direct binding when needed
    property string searchQuery: ""
    readonly property list<string> extensions: [ // TODO: add videos
        "jpg", "jpeg", "png", "webp", "avif", "bmp", "svg", "mp4", "mkv", "webm", "avi", "mov", "m4v", "ogv"
    ]
    property list<string> wallpapers: [] // List of absolute file paths (without file://)
    readonly property bool thumbnailGenerationRunning: thumbgenProc.running
    property real thumbnailGenerationProgress: 0
    property var colorCache: ({})
    property string sortField: "modified"
    property bool sortReversed: false
    property var creationTimes: ({})
    property list<string> pendingCreationPaths: []
    property alias sortedFolderModel: sortedFolderModel
    signal sortChanged()

    signal changed()
    signal thumbnailGenerated(directory: string)
    signal thumbnailGeneratedFile(filePath: string)

    function load () {} // For forcing initialization

    property list<string> videoExtensions: [
        "mp4", "mkv", "webm", "avi", "mov", "m4v", "ogv"
    ]
    function isVideoFile(name) {
        return videoExtensions.some(ext => name.endsWith("." + ext))
    }

    // Executions
    Process {
        id: applyProc
    }

    Connections {
        target: Config
        function onReadyChanged() { // Apply wallpaper on config ready if it's a video
            if (!Config.ready || !root.isVideoFile(Config.options.background.wallpaperPath.toLowerCase())) return;
            root.apply(Config.options.background.wallpaperPath, Appearance.m3colors.darkmode);
        }
    }
    
    function openFallbackPicker(darkMode = Appearance.m3colors.darkmode, lockscreen = false) {
        Quickshell.execDetached([Directories.wallpaperSwitchScriptPath, "--mode", darkMode ? "dark" : "light"]);
    }

    function apply(path, darkMode = Appearance.m3colors.darkmode) {
        if (!path || path.length === 0) return;
        Quickshell.execDetached([Directories.wallpaperSwitchScriptPath, "--mode", darkMode ? "dark" : "light", "--image", path]);
        root.changed()
    }

    Process {
        id: selectProc
        property string filePath: ""
        property bool darkMode: Appearance.m3colors.darkmode
        function select(filePath, darkMode = Appearance.m3colors.darkmode) {
            selectProc.filePath = filePath
            selectProc.darkMode = darkMode
            selectProc.exec(["test", "-d", FileUtils.trimFileProtocol(filePath)])
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                setDirectory(selectProc.filePath);
                return;
            }
            root.apply(selectProc.filePath, selectProc.darkMode);
        }
    }

    function select(filePath, darkMode = Appearance.m3colors.darkmode) {
        selectProc.select(filePath, darkMode);
    }

    function randomFromCurrentFolder(darkMode = Appearance.m3colors.darkmode) {
        if (folderModel.count === 0) return;
        const randomIndex = Math.floor(Math.random() * folderModel.count);
        const filePath = folderModel.get(randomIndex, "filePath");
        print("Randomly selected wallpaper:", filePath);
        root.select(filePath, darkMode);
    }

    function normalizeSortField(value) {
        const field = String(value || "modified");
        return ["name", "modified", "created", "size"].includes(field) ? field : "modified";
    }

    function normalizeDateValue(value) {
        if (typeof value === "number" && isFinite(value)) {
            return (value > 0 && value < 10000000000) ? value * 1000 : value;
        }
        if (value && typeof value.toMSecsSinceEpoch === "function") {
            const milliseconds = Number(value.toMSecsSinceEpoch());
            if (isFinite(milliseconds)) return milliseconds;
        }
        if (value && typeof value.getTime === "function") {
            const milliseconds = Number(value.getTime());
            if (isFinite(milliseconds)) return milliseconds;
        }
        const parsed = Date.parse(String(value || ""));
        return isFinite(parsed) ? parsed : 0;
    }

    function sortValue(entry) {
        switch (root.sortField) {
        case "name":
            return entry.fileName.toLocaleLowerCase();
        case "created":
            return entry.fileCreated > 0 ? entry.fileCreated : entry.fileLastModified;
        case "size":
            return entry.fileSize;
        case "modified":
        default:
            return entry.fileLastModified;
        }
    }

    function rebuildSortedFolderModel() {
        const entries = [];
        for (let i = 0; i < folderModel.count; i++) {
            const filePath = String(folderModel.get(i, "filePath") || FileUtils.trimFileProtocol(folderModel.get(i, "fileUrl") || folderModel.get(i, "fileURL") || ""));
            if (!filePath) continue;
            const normalizedPath = FileUtils.trimFileProtocol(filePath);
            const fileModifiedRaw = folderModel.get(i, "fileModified") ?? folderModel.get(i, "fileLastModified");
            entries.push({
                filePath: filePath,
                fileUrl: String(folderModel.get(i, "fileUrl") || folderModel.get(i, "fileURL") || filePath),
                fileName: String(folderModel.get(i, "fileName") || ""),
                fileBaseName: String(folderModel.get(i, "fileBaseName") || ""),
                fileSuffix: String(folderModel.get(i, "fileSuffix") || ""),
                fileSize: Number(folderModel.get(i, "fileSize") || 0),
                fileLastModified: root.normalizeDateValue(fileModifiedRaw),
                fileCreated: Number(root.creationTimes[normalizedPath] || 0),
                fileIsDir: Boolean(folderModel.get(i, "fileIsDir"))
            });
        }
        entries.sort((left, right) => {
            if (left.fileIsDir !== right.fileIsDir) {
                return left.fileIsDir ? -1 : 1;
            }
            const leftValue = root.sortValue(left);
            const rightValue = root.sortValue(right);
            let comparison = 0;
            if (typeof leftValue === "string") {
                comparison = leftValue.localeCompare(rightValue);
            } else {
                if (leftValue > rightValue) comparison = -1;
                else if (leftValue < rightValue) comparison = 1;
            }
            if (root.sortReversed) comparison = -comparison;
            if (comparison === 0) {
                comparison = left.fileName.toLocaleLowerCase().localeCompare(right.fileName.toLocaleLowerCase());
            }
            return comparison;
        });
        sortedFolderModel.clear();
        for (let i = 0; i < entries.length; i++) {
            sortedFolderModel.append(entries[i]);
        }
    }

    function refreshCreationTimes() {
        const paths = [];
        for (let i = 0; i < folderModel.count; i++) {
            const filePath = String(folderModel.get(i, "filePath") || "");
            if (filePath) paths.push(FileUtils.trimFileProtocol(filePath));
        }
        root.pendingCreationPaths = paths;
        if (paths.length === 0) {
            root.creationTimes = ({});
            root.rebuildSortedFolderModel();
            return;
        }
        creationTimesProc.command = [
            "bash", "-c",
            "for path do stat -c '%W' -- \"$path\" 2>/dev/null || printf '0\\n'; done",
            "wallpaper-birth-times"
        ].concat(paths);
        creationTimesProc.running = true;
        root.rebuildSortedFolderModel();
    }

    function queueFolderModelRefresh() {
        folderModelRefreshTimer.restart();
    }

    function applyNativeSort() {
        if (root.sortField === "name") {
            folderModel.sortField = FolderListModel.Name;
        } else if (root.sortField === "size") {
            folderModel.sortField = FolderListModel.Size;
        } else {
            folderModel.sortField = FolderListModel.Time;
        }
        folderModel.sortReversed = root.sortReversed;
    }

    function loadSortOptions() {
        const options = Config.options?.wallpaperSelector;
        root.sortField = root.normalizeSortField(options?.sortField);
        root.sortReversed = options?.sortReversed === true;
        root.applyNativeSort();
        root.queueFolderModelRefresh();
    }

    function selectSortField(field) {
        const nextField = root.normalizeSortField(field);
        if (root.sortField === nextField) {
            root.sortReversed = !root.sortReversed;
        } else {
            root.sortField = nextField;
            root.sortReversed = false;
        }
        Config.options.wallpaperSelector.sortField = root.sortField;
        Config.options.wallpaperSelector.sortReversed = root.sortReversed;
        Config.saveOptionsNow();
        root.applyNativeSort();
        root.rebuildSortedFolderModel();
        root.sortChanged();
    }

    Process {
        id: validateDirProc
        property string nicePath: ""
        function setDirectoryIfValid(path) {
            validateDirProc.nicePath = FileUtils.trimFileProtocol(path).replace(/\/+$/, "")
            if (/^\/*$/.test(validateDirProc.nicePath)) validateDirProc.nicePath = "/";
            validateDirProc.exec([
                "bash", "-c",
                `if [ -d "${validateDirProc.nicePath}" ]; then echo dir; elif [ -f "${validateDirProc.nicePath}" ]; then echo file; else echo invalid; fi`
            ])
        }
        stdout: StdioCollector {
            onStreamFinished: {
                    root.directory = Qt.resolvedUrl(validateDirProc.nicePath)
                const result = text.trim()
                if (result === "dir") {
                } else if (result === "file") {
                    root.directory = Qt.resolvedUrl(FileUtils.parentDirectory(validateDirProc.nicePath))
                } else {
                    // Ignore
                }
            }
        }
    }
    function setDirectory(path) {
        validateDirProc.setDirectoryIfValid(path)
    }
    function navigateUp() {
        folderModel.navigateUp()
    }
    function navigateBack() {
        folderModel.navigateBack()
    }
    function navigateForward() {
        folderModel.navigateForward()
    }

    // Folder model
    FolderListModelWithHistory {
        id: folderModel
        folder: Qt.resolvedUrl(root.defaultFolder)
        caseSensitive: false
        nameFilters: root.extensions.map(ext => `*${searchQuery.split(" ").filter(s => s.length > 0).map(s => `*${s}*`)}*.${ext}`)
        showDirs: true
        showDotAndDotDot: false
        showOnlyReadable: true
        sortField: FolderListModel.Time
        sortReversed: false
        onCountChanged: {
            root.wallpapers = []
            for (let i = 0; i < folderModel.count; i++) {
                const path = folderModel.get(i, "filePath") || FileUtils.trimFileProtocol(folderModel.get(i, "fileURL"))
                if (path && path.length) root.wallpapers.push(path)
            }
            root.queueFolderModelRefresh();
        }
        onFolderChanged: {
            root.queueFolderModelRefresh();
        }
        onStatusChanged: {
            if (folderModel.status === FolderListModel.Ready) {
                root.queueFolderModelRefresh();
            }
        }
    }

    Timer {
        id: folderModelRefreshTimer
        interval: 100
        repeat: false
        onTriggered: root.refreshCreationTimes()
    }

    Process {
        id: creationTimesProc
        stdout: StdioCollector {
            onStreamFinished: {
                const values = text.trim().length > 0 ? text.trim().split(/\r?\n/) : [];
                const nextCreationTimes = ({});
                for (let i = 0; i < root.pendingCreationPaths.length; i++) {
                    const value = Number(values[i] || 0);
                    const ms = (isFinite(value) && value > 0) ? (value < 10000000000 ? value * 1000 : value) : 0;
                    nextCreationTimes[root.pendingCreationPaths[i]] = ms;
                }
                root.creationTimes = nextCreationTimes;
                root.rebuildSortedFolderModel();
            }
        }
    }

    ListModel {
        id: sortedFolderModel
    }

    // Thumbnail generation
    function generateThumbnail(size: string) {
        if (!["normal", "large", "x-large", "xx-large"].includes(size)) throw new Error("Invalid thumbnail size");
        thumbgenProc.directory = root.directory
        thumbgenProc.running = false
        thumbgenProc.command = [
            "bash", "-c",
            `${thumbgenScriptPath} --size ${size} --machine_progress -d ${FileUtils.trimFileProtocol(root.directory)} || ${generateThumbnailsMagickScriptPath} --size ${size} -d ${FileUtils.trimFileProtocol(root.directory)}`,
        ]
        // console.log("[Wallpapers] Updating thumbnails with command ", thumbgenProc.command.join(" "))
        root.thumbnailGenerationProgress = 0
        thumbgenProc.running = true
    }
    Process {
        id: thumbgenProc
        property string directory
        stdout: SplitParser {
            onRead: data => {
                // print("thumb gen proc:", data)
                let match = data.match(/PROGRESS (\d+)\/(\d+)/)
                if (match) {
                    const completed = parseInt(match[1])
                    const total = parseInt(match[2])
                    root.thumbnailGenerationProgress = completed / total
                }
                match = data.match(/FILE (.+)/)
                if (match) {
                    const filePath = match[1]
                    root.thumbnailGeneratedFile(filePath)
                }
            }
        }
        onExited: (exitCode, exitStatus) => {
            // print("[Wallpapers] Thumbnail generation completed with exit code", exitCode)
            root.thumbnailGenerated(thumbgenProc.directory)
        }
    }

    Process {
        id: readColorCacheProc
        stdout: StdioCollector {
            onStreamFinished: {
                if (text && text.trim().length > 0) {
                    try {
                        root.colorCache = JSON.parse(text);
                    } catch (e) {
                        console.error("[Wallpapers] Failed to parse color cache:", e);
                    }
                }
            }
        }
    }

    function loadColorCache() {
        const path = Directories.colorCachePath;
        readColorCacheProc.exec(["cat", path]);
    }

    Component.onCompleted: {
        root.loadColorCache();
        if (Config.ready) root.loadSortOptions();
    }

    Connections {
        target: Config
        function onReadyChanged() {
            if (Config.ready) root.loadSortOptions();
        }
    }

    IpcHandler {
        target: "wallpapers"

        function apply(path: string): void {
            root.apply(path);
        }
    }
}
