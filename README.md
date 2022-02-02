[![LICENSE](https://img.shields.io/badge/license-EUPL_v1.2-blue.svg)](https://raw.githubusercontent.com/misery/DockerAusweisApp2/master/LICENSE.txt)

# Vollautomatisches Auslesen von Testausweisen

Ziel dieses Projektes ist es, ohne Interaktion durch eine Person mit dem Ausweissimulator **PersoSim** oder dem eID-Client **AusweisApp2** auslesen zu können, um in Web-Anwendungen diese Funktion e2e-testbar zu machen.

## Docker Container bauen

```
docker build -t ausweisapp2persosim:2.0 .
```
## Ausführen

```
docker run -d --restart unless-stopped --name ausweisapp2persosim --net=host ausweisapp2persosim:2.0
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
    docker run -d --rm --name temp-container --volumes-from x11-bridge -v $(pwd)/files/config:/home/ausweisapp/.config -e DISPLAY=:14 -e LANG=DE --net host ausweisapp2persosim:withoutconfig
    ```
2. Die GUIs im Browser unter http://localhost:10000/index.html?encoding=rgb32&password=111# öffnen.
3. AusweisApp2 und PersoSim über die GUIs konfigurieren.
4. Optional: Einen Ausweisvorgang zum Testen durchführen.
5. Die relevanten Dateien von `/home/ausweisapp/.config` des Containers werden in den [`files/config/`](./files/config/)-Ordner dieses Repositorys geschrieben.

# LICENSE

EUPL v1.2

## DockerAusweisApp2
Dies ist ein Fork von https://github.com/misery/DockerAusweisApp2, welches mit EUPL v1.2 lizenziert ist.

## AusweisApp2
Der Quellcode der AusweisApp2 ist unter der EUPL v1.2 bereitgestellt, mit Ausnahme der Bibliothek OpenSSL, die unter der OpenSSL License / SSLeay License lizensiert ist. (Ist nicht Teil dieses Repositorys.)

## PersoSim
PersoSim is licensed under the GNU General Public License v3.0. (Ist nicht Teil dieses Repositorys.)