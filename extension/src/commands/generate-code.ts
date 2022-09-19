import { commands, Selection, Uri, window, workspace } from 'vscode';
export const command = 'bigorm.model.generateCode';

export default async function generateCode() {
    const language = await window.showQuickPick(['Hibernate', 'SQLAlchemy', 'Entity Framework'], {
        placeHolder: 'Select language to generate code for.'
    });
    window.showInformationMessage(`Got: ${language}`);
    let activeEditor = window.activeTextEditor;

    if (!activeEditor || !activeEditor.document || activeEditor.document.languageId !== 'bigorm') {
        console.log("Can't execute command");
        return;
    }

    if (activeEditor.document.uri instanceof Uri) {
        const args = {"file": activeEditor.document.uri.toString(), "language": language};
        commands.executeCommand("big.orm.command.generate", args).then(((answer) => { console.log(answer) }));
    }
}