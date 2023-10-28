/** @jsx svg */
import { inject, injectable } from "inversify";
import { VNode } from "snabbdom";
import { RenderingContext, svg, PolylineEdgeView, SEdge, EdgeRouterRegistry, SGraphView, IView} from "sprotty";
import { Point, SPort, toDegrees } from "sprotty-protocol";
import { OrmModelGraph, OrmModelRelationshipEdge } from "./model";
import { UITypes } from "./utils";


@injectable()
export class OrmModelView<IRenderingArgs> extends SGraphView<IRenderingArgs> {

    @inject(EdgeRouterRegistry) edgeRouterRegistry: EdgeRouterRegistry;

    render(model: Readonly<OrmModelGraph>, context: RenderingContext, args?: IRenderingArgs): VNode {
        // set model name in toolbar
        const menuModelName = document.getElementById(UITypes.MODEL_NAME);
        if (menuModelName) {
            menuModelName.innerText = model.name;
        }
        const edgeRouting = this.edgeRouterRegistry.routeAllChildren(model);
        const transform = `scale(${model.zoom}) translate(${-model.scroll.x},${-model.scroll.y})`;
        return <svg class-sprotty-graph={true}>
            <g transform={transform}>
                {context.renderChildren(model, { edgeRouting })}
            </g>
        </svg>;
    }
}

@injectable()
export class RelationshipEdgeView extends PolylineEdgeView {
    protected renderAdditionals(edge: SEdge, segments: Point[], context: RenderingContext): VNode[] {
        const firstPoint = segments[0];
        const secondPoint = segments[1];
        const secondToLastPoint = segments[segments.length - 2];
        const lastPoint = segments[segments.length - 1];

        const arrows = [];

        arrows.push(<path class-sprotty-edge-arrow={true} d="M 6,-3 L 0,0 L 6,3 Z"
            transform={`rotate(${angle(lastPoint, secondToLastPoint)} ${lastPoint.x} ${lastPoint.y}) translate(${lastPoint.x} ${lastPoint.y})`}/>);

        if (edge instanceof OrmModelRelationshipEdge) {
            if (!edge.unidirectional) {
                arrows.push(<path class-sprotty-edge-arrow={true} d="M 6,-3 L 0,0 L 6,3 Z"
                    transform={`rotate(${angle(firstPoint, secondPoint)} ${firstPoint.x} ${firstPoint.y}) translate(${firstPoint.x} ${firstPoint.y})`}/>);
            }
        }
        return arrows;
    }
}

@injectable()
export class InheritanceEdgeView extends PolylineEdgeView {
    protected renderAdditionals(edge: SEdge, segments: Point[], context: RenderingContext): VNode[] {
        const secondToLastPoint = segments[segments.length - 2];
        const lastPoint = segments[segments.length - 1];

        const arrows = [];

        arrows.push(<path class-sprotty-edge-arrow={true} stroke-width={1} fill={"red"} d="M 8,-4 L 0,0 L 8,4 L 16,0 Z"
            transform={`rotate(${angle(lastPoint, secondToLastPoint)} ${lastPoint.x} ${lastPoint.y}) translate(${lastPoint.x} ${lastPoint.y})`}/>);
        return arrows;
    }
}

export function angle(x0: Point, x1: Point): number {
    return toDegrees(Math.atan2(x1.y - x0.y, x1.x - x0.x));
}

@injectable()
export class TriangleButtonView implements IView {
    render(model: SPort, context: RenderingContext): VNode {
        return <path class-sprotty-button={true} d="M 0,0 L 8,4 L 0,8 Z" />;
    }
}