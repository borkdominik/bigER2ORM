import { RectangularNode, SRoutableElement } from 'sprotty';


export class EntityNode extends RectangularNode {
    canConnect(routable: SRoutableElement, role: string) {
        return true;
    }}