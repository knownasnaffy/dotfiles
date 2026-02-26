// import qs.Services

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common.Utils
pragma Singleton

Singleton {
    id: root

    property alias caffeine: adapter.caffeine
    property alias notifications: adapter.notifications // This should only be managed by the `Notifications` service
    property alias launcher: adapter.launcher

    FileView {
        path: Paths.cacheFile
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoadFailed: (err) => {
            if (err === FileViewError.FileNotFound)
                writeAdapter();

        }

        JsonAdapter {
            id: adapter

            property JsonObject caffeine

            caffeine: JsonObject {
                property int mode: Caffeine.Mode.PreventSleep
                property bool running: false
            }

            property JsonObject notifications

            notifications: JsonObject {
                property bool doNotDisturb: false
            }

            property JsonObject launcher

            launcher: JsonObject {
                property bool useGrid: false
            }

        }

    }

}
