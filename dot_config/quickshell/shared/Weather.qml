pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property bool useCelsius: Config.useCelsius

    property string location: Config.weatherLocation
    property string temp: "--"
    property string icon: "\u{f0590}"
    property string description: "--"
    property string feelsLike: "--"
    property string humidity: "--"
    property string wind: "--"
    property var forecast: []
    property string status: "loading"  // "loading", "ok", "error"

    function weatherIcon(code) {
        code = parseInt(code);
        if (code === 113) return "\u{f0599}";
        if (code === 116) return "\u{f0595}";
        if (code <= 122) return "\u{f0590}";
        if (code <= 260) return "\u{f0591}";
        if ([176,263,266,293,296,299,302,305,308,353,356,359].includes(code)) return "\u{f0597}";
        return "\u{f0598}";
    }

    Process {
        id: weatherProc
        command: ["sh", "-c", "curl -sf 'wttr.in/" + Config.weatherLocation + "?format=j1' 2>/dev/null"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let data = JSON.parse(this.text);
                    let cur = data.current_condition[0];
                    let tempKey = root.useCelsius ? "temp_C" : "temp_F";
                    let feelsKey = root.useCelsius ? "FeelsLikeC" : "FeelsLikeF";
                    let windKey = root.useCelsius ? "windspeedKmph" : "windspeedMiles";
                    let maxKey = root.useCelsius ? "maxtempC" : "maxtempF";
                    let minKey = root.useCelsius ? "mintempC" : "mintempF";

                    root.temp = cur[tempKey] + Config.tempUnit;
                    root.feelsLike = cur[feelsKey] + Config.tempUnit;
                    root.humidity = cur.humidity + "%";
                    root.wind = cur[windKey] + " " + Config.windUnit;
                    root.description = cur.weatherDesc[0].value;
                    root.location = data.nearest_area[0].areaName[0].value;
                    root.icon = root.weatherIcon(cur.weatherCode);

                    let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
                    let fc = [];
                    let weather = data.weather || [];
                    for (let i = 0; i < Math.min(weather.length, Config.forecastDays); i++) {
                        let w = weather[i];
                        let d = new Date(w.date);
                        fc.push({
                            day: days[d.getDay()],
                            high: w[maxKey],
                            low: w[minKey],
                            code: w.hourly[4].weatherCode,
                            desc: w.hourly[4].weatherDesc[0].value
                        });
                    }
                    root.forecast = fc;
                    root.status = "ok";
                } catch(e) {
                    console.warn("Weather: failed to parse response:", e);
                    root.status = root.temp === "--" ? "error" : "stale";
                }
            }
        }
    }

    Timer {
        interval: Config.weatherRefreshMs
        running: true
        repeat: true
        onTriggered: weatherProc.running = true
    }
}
