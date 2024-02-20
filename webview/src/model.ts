import { RectangularNode, SEdge, SGraph } from 'sprotty';


export class OrmModelGraph extends SGraph {
    name: string;
}

export class OrmModelNode extends RectangularNode {
    expanded: boolean;
}

export class OrmModelRelationshipEdge extends SEdge {
    unidirectional: boolean;
}