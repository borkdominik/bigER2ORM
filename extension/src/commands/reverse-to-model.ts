import path = require('path');
import { commands, OpenDialogOptions, Uri, window, workspace } from 'vscode';
export const command = 'bigorm.model.reverseToModel';

const optionsInput: OpenDialogOptions = {
    canSelectMany: false,
    openLabel: 'Select as input',
    canSelectFiles: true,
    canSelectFolders: true,
    title: 'Select files to reverse'
};

const optionsOutput: OpenDialogOptions = {
    canSelectMany: false,
    openLabel: 'Select for output',
    canSelectFiles: false,
    canSelectFolders: true,
    title: 'Select output folder'
};

export default async function reverseToModel() {
    const fileInput = await window.showOpenDialog(optionsInput);

    if (!(fileInput && fileInput[0])) {
        console.log("No file selected");
        return;
    }
    console.log('Selected file: ' + fileInput[0].toString());

    const fileOutputPath = await window.showOpenDialog(optionsOutput);

    if (!(fileOutputPath && fileOutputPath[0])) {
        console.log("No output path selected");
        return;
    }
    console.log('Selected output path: ' + fileOutputPath[0].toString());

    const model_name = await window.showInputBox({
        placeHolder: 'Select name of model to create'
    });
    if (!model_name) {
        console.log("No model name entered");
        return;
    }
    console.log('Model name: ' + model_name);

    const args = {"fileInput": fileInput[0].toString(), "fileOutput": fileOutputPath[0].toString(), "modelName": model_name};
    let answer = await commands.executeCommand("big.orm.command.reverse", args);
    console.log(answer) 

    const filePath = path.join(fileOutputPath[0].path, model_name + ".orm")
    const openPath = Uri.file(filePath);
    workspace.openTextDocument(openPath).then(doc => {
        window.showTextDocument(doc);
    });
}