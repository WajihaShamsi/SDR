"use strict";
class InstrumentsWidget {
    constructor(document, driver) {
        this.driver = driver;
        this.writeImageVersion();
        this.instrumentsTable = document.getElementById('instruments-table');
        this.isUpdate = true;
        this.update();
        this.uploadInput = document.getElementById("upload-input");
        this.uploadStatus = document.getElementById("upload-status");
    }
    update() {
        if (this.isUpdate) {
            this.driver.getInstrumentsStatus((status) => {
                let instruments = status['instruments'];
                let liveInstrument = status['live_instrument'];
                this.instrumentsTable.innerHTML = '<thead><tr><th>Name</th><th>Status</th><th colspan="2">Action</th><th>Version</th></tr></thead>';
                for (let instrument of instruments) {
                    let row = this.instrumentsTable.insertRow(-1);
                    let nameCell = row.insertCell(0);
                    let statusCell = row.insertCell(1);
                    let runCell = row.insertCell(2);
                    let deleteCell = row.insertCell(3);
                    let versionCell = row.insertCell(4);
                    let isLive = false;
                    let isDefault = false;
                    for (let cell of [nameCell, statusCell, runCell, deleteCell, versionCell]) {
                        cell.style["border-left"] = 'none';
                        cell.style["border-right"] = 'none';
                        cell.style["border-top"] = "1px solid #ddd";
                        cell.style["border-bottom"] = "none";
                        cell.style.verticalAlign = 'middle';
                    }
                    if (instrument["name"] == liveInstrument["name"]) {
                        isLive = true;
                    }
                    ;
                    if (instrument["is_default"]) {
                        isDefault = true;
                    }
                    this.setStatusCell(statusCell, isLive);
                    this.setRunCell(runCell, instrument["name"], isLive);
                    this.setDeleteCell(deleteCell, instrument["name"], isLive, isDefault);
                    nameCell.innerHTML = instrument["name"];
                    versionCell.innerHTML = instrument["version"];
                }
                this.isUpdate = false;
                document.body.style.cursor = "default";
            });
        }
        ;
        setTimeout(() => {
            this.update(), 200;
        });
    }
    writeImageVersion() {
        $.getJSON("version.json", function (data) {
            this.imageVersionSpan = document.getElementById("image-version");
            this.imageVersionSpan.innerHTML = data["version"];
        });
    }
    setStatusCell(cell, isLive) {
        if (isLive) {
            cell.innerHTML = '<a href="/">Running</a>';
        }
        else {
            cell.innerHTML = '';
        }
    }
    setRunCell(cell, name, isLive) {
        if (isLive) {
            cell.innerHTML = '';
        }
        else {
            cell.innerHTML = '<a onclick="instruments_widget.runClick(this.parentNode, \'' + name + '\'); return false;" href="#">Run</a>';
        }
    }
    runClick(cell, name) {
        document.body.style.cursor = "wait";
        this.driver.runInstrument(name, (err) => {
            document.body.style.cursor = "default";
            location.href = "/";
        });
    }
    setDeleteCell(cell, name, isLive, isDefault) {
        if (isLive) {
            cell.innerHTML = "Live";
            cell.style.color = "#737373";
        }
        else if (isDefault) {
            cell.innerHTML = "Default";
            cell.style.color = "#737373";
        }
        else {
            cell.innerHTML = '<a onclick="instruments_widget.deleteClick(this.parentNode, \'' + name + '\'); return false;" href="#">Remove</a>';
        }
    }
    deleteClick(cell, name) {
        document.body.style.cursor = "wait";
        this.driver.deleteInstrument(name);
        this.isUpdate = true;
    }
    uploadInstrumentClick() {
        this.uploadStatus.innerHTML = "";
        let file = this.uploadInput.files[0];
        if ((file.name).indexOf(".zip") !== -1) {
            this.driver.uploadInstrument(file, (status) => {
                this.isUpdate = status;
            });
        }
        else {
            this.uploadStatus.innerHTML = "Select ZIP file";
        }
    }
}
