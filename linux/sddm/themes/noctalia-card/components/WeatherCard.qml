pragma ComponentBehavior: Bound
import QtQuick
import "util.js" as U

// Current weather and a 3-day forecast from Open-Meteo, for the location in
// <assetsDir>/location.json (Noctalia's, synced). SDDM doesn't wait for the
// network, so a failed fetch retries every 30 s and the card stays empty
// until one works; after that it refreshes every 30 min.
Card {
    id: root

    property string assetsDir
    property int forecastDays: 3
    property string place: ""
    property var current: null
    property var days: []

    // WMO weather code to a Material Symbols glyph and a short description.
    function describe(code, isDay) {
        if (code === 0)
            return [isDay ? "sunny" : "clear_night", "Clear"];
        if (code <= 2)
            return [isDay ? "partly_cloudy_day" : "partly_cloudy_night", "Partly cloudy"];
        if (code === 3)
            return ["cloud", "Overcast"];
        if (code <= 48)
            return ["foggy", "Fog"];
        if (code <= 57)
            return ["grain", "Drizzle"];
        if (code <= 67 || (code >= 80 && code <= 82))
            return ["rainy", "Rain"];
        if (code <= 77 || code === 85 || code === 86)
            return ["weather_snowy", "Snow"];
        return ["thunderstorm", "Thunderstorm"];
    }

    function get(url, done) {
        const xhr = new XMLHttpRequest();
        xhr.onreadystatechange = () => {
            if (xhr.readyState === XMLHttpRequest.DONE)
                done(xhr.status === 200 || (xhr.status === 0 && xhr.responseText.length > 0) ? xhr.responseText : null);
        };
        xhr.open("GET", url);
        xhr.send();
    }

    function fetch() {
        get(U.asset(assetsDir, "location.json"), text => {
            let loc = null;
            try {
                loc = text ? JSON.parse(text) : null;
            } catch (e) {}
            if (!loc || loc.latitude === undefined) {
                retry.restart();
                return;
            }
            place = (loc.name || "").split(",")[0];
            const url = "https://api.open-meteo.com/v1/forecast?latitude=" + loc.latitude + "&longitude=" + loc.longitude + "&current=temperature_2m,weather_code,is_day" + "&daily=weather_code,temperature_2m_max,temperature_2m_min" + "&timezone=auto&forecast_days=" + (forecastDays + 1);
            get(url, body => {
                let data = null;
                try {
                    data = body ? JSON.parse(body) : null;
                } catch (e) {}
                if (!data || !data.current || !data.daily) {
                    retry.restart();
                    return;
                }
                current = data.current;
                const list = [];
                for (let i = 1; i <= forecastDays && i < data.daily.time.length; i++)
                    list.push({
                        "date": new Date(data.daily.time[i] + "T12:00:00"),
                        "code": data.daily.weather_code[i],
                        "max": Math.round(data.daily.temperature_2m_max[i]),
                        "min": Math.round(data.daily.temperature_2m_min[i])
                    });
                days = list;
                refresh.restart();
            });
        });
    }

    Component.onCompleted: fetch()

    Timer {
        id: retry

        interval: 30000
        onTriggered: root.fetch()
    }

    Timer {
        id: refresh

        interval: 1800000
        onTriggered: root.fetch()
    }

    Column {
        anchors.centerIn: parent
        width: parent.width - 56
        spacing: 30
        visible: root.current !== null

        Row {
            spacing: 18

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                text: root.current ? root.describe(root.current.weather_code, root.current.is_day)[0] : ""
                size: 100
                filled: true
                color: config.primary
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    text: root.current ? Math.round(root.current.temperature_2m) + "°" : ""
                    color: config.text
                    font.family: "Google Sans Flex"
                    font.pixelSize: 64
                    font.weight: Font.DemiBold
                }

                Text {
                    text: root.current ? root.describe(root.current.weather_code, root.current.is_day)[1] : ""
                    color: config.text
                    opacity: 0.8
                    font.family: "Google Sans Flex"
                    font.pixelSize: 17
                }

                Text {
                    text: root.place
                    visible: text.length > 0
                    color: config.outline
                    font.family: "Google Sans Flex"
                    font.pixelSize: 15
                }
            }
        }

        Row {
            width: parent.width

            Repeater {
                model: root.days

                Column {
                    id: day

                    required property var modelData

                    width: parent.width / root.forecastDays
                    spacing: 8

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Qt.formatDate(day.modelData.date, "ddd").toUpperCase()
                        color: config.outline
                        font.family: "Google Sans Flex"
                        font.pixelSize: 13
                        font.weight: Font.Bold
                        font.letterSpacing: 1.5
                    }

                    Icon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.describe(day.modelData.code, 1)[0]
                        size: 42
                        color: config.secondary
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: day.modelData.max + "° / " + day.modelData.min + "°"
                        color: config.text
                        font.family: "Google Sans Flex"
                        font.pixelSize: 16
                    }
                }
            }
        }
    }
}
