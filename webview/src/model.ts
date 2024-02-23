import { RectangularNode, SEdgeImpl, SGraphImpl } from 'sprotty';


export class OrmModelGraph extends SGraphImpl {
    name: string;
}

export class OrmModelNode extends RectangularNode {
    expanded: boolean;
}

export class OrmModelRelationshipEdge extends SEdgeImpl {
    unidirectional: boolean;
}