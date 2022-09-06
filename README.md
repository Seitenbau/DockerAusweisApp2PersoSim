[![LICENSE](https://img.shields.io/badge/license-EUPL_v1.2-blue.svg)](https://raw.githubusercontent.com/misery/DockerAusweisApp2/master/LICENSE.txt)

# Archiviert

Dieses Projekt wird nicht weiterentwicklet, da die Funktionen inzwischen in V1.24 der AusweisApp2 aufgenommen wurden (siehe [Changelog 1.24.0](https://github.com/Governikus/AusweisApp2/releases/tag/1.24.0)).

Es steht ein offizielles Dockerimage [governikus/ausweisapp2](https://hub.docker.com/r/governikus/ausweisapp2) (Verwendung siehe [Doku](https://www.ausweisapp.bund.de/sdk/container.html)) zur Verfügung, das dieses Projket überflüssig macht.

# Vollautomatisches Auslesen von Testausweisen

Ziel dieses Projektes ist es, ohne Interaktion durch eine Person mit dem Ausweissimulator **PersoSim** oder dem eID-Client **AusweisApp2** auslesen zu können, um in Web-Anwendungen diese Funktion e2e-testbar zu machen.

## Docker Container bauen

```
docker build -t ausweisapp2persosim:2.0 .
```
## Ausführen

```
docker run -d --restart unless-stopped --name ausweisapp2persosim -p 24727:24730 ausweisapp2persosim:2.0
```

Jetzt kann ein Ausweisvorgang gestart werden. Nach ca. 10s ist der Testausweis ohne jegliches zutun durch eine Person ausgelesen.

## technischer Hintergrund

### Änderung an der AusweisApp2
Der "Weiter zur PIN-Eingabe"-Button wird automatisch nach vier Sekunden geklickt (siehe [`files/ausweisApp2-automation.patch`](./files/ausweisApp2-automation.patch)).

### Änderung an PersoSim
Die Autologin-Funktion wird persistiert (siehe https://github.com/PersoSim/de.persosim.driver.connector/pull/21). Um den aufwendigen Build davon nicht machen zu müssen, ist das Build-Ergebnis in Form der `de.persosim.driver.connector.ui_0.17.2.20210224.jar` im Repo https://github.com/Seitenbau/de.persosim.driver.connector/ released.

### Verknüpfung von AusweisApp2 und PersoSim

Die Verknüpfung von AusweisApp2 und PersoSim sowie die AutoLogin Aktivierung ist in den Dateien im [`files/config/`](./files/config/)-Ordner vorkonfiguriert.

Dies kann man machen, indem man wie folgt vorgeht

1. AusweisApp2 und PersoSim starten
    ```
    docker run -d --name x11-bridge -e MODE="tcp" -e XPRA_HTML="yes" -e DISPLAY=:14 -e XPRA_PASSWORD=111 -p 10000:10000  jare/x11-bridge
    docker run -d --rm --name temp-container --volumes-from x11-bridge -v $(pwd)/files/config:/home/ausweisapp/.config -e DISPLAY=:14 -e LANG=DE -p 24727:24730 ausweisapp2persosim:withoutconfig
    ```
2. Die GUIs im Browser unter http://localhost:10000/index.html?encoding=rgb32&password=111# öffnen.
3. AusweisApp2 und PersoSim über die GUIs konfigurieren.
4. Optional: Einen Ausweisvorgang zum Testen durchführen.
5. Die relevanten Dateien von `/home/ausweisapp/.config` des Containers werden in den [`files/config/`](./files/config/)-Ordner dieses Repositorys geschrieben.

### Netzwerktechnische Verknüpfung des Containers mit dem Hostsystem, das die AusweisApp2 nutzen will

Die AusweisApp2 lässt nur Verbindungen von localhost zu. Daher reicht es nicht den Port 24727 des Containers zu exponieren. Die Option `--net=host` funktioniert nur unter Linux oder in der WSL2. Docker Desktop für Mac und Windows unterstützt dies (meist) nicht. Aus dem Grund wird im Container ein `caddy reverse-proxy` gestartet, welcher auf Port 24730 hört und der AusweisApp2 vorgaukelt, dass Anfragen von localhost (innerhalb des Containers) kämen.

Dies hat zur Folge, dass beim Start des Containers der exponierte Port 24730 des Containers auf den Port 24727 des Hostsystems gemappt werden muss (`-p 24727:24730`).

Beim Betreib innerhalb eines Pods mit Containern für e2e-Tests, ist der `caddy reverse-proxy` nicht zwingend nötig.

# LICENSE

EUPL v1.2

## DockerAusweisApp2
Dies ist ein Fork von https://github.com/misery/DockerAusweisApp2, welches mit EUPL v1.2 lizenziert ist.

## AusweisApp2
Der Quellcode der AusweisApp2 ist unter der EUPL v1.2 bereitgestellt, mit Ausnahme der Bibliothek OpenSSL, die unter der OpenSSL License / SSLeay License lizensiert ist. (Ist nicht Teil dieses Repositorys.)

## PersoSim
PersoSim is licensed under the GNU General Public License v3.0. (Ist nicht Teil dieses Repositorys.)