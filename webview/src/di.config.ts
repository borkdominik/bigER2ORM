import { Container, ContainerModule } from "inversify";
import { LibavoidDiamondAnchor, LibavoidEllipseAnchor, LibavoidRectangleAnchor, LibavoidRouter, RouteType } from 'sprotty-routing-libavoid';
import 'sprotty/css/command-palette.css';
import 'sprotty/css/sprotty.css';
import '../css/diagram.css';


import {
    configureModelElement, ConsoleLogger, DiamondNodeView, editFeature, editLabelFeature, ExpandButtonHandler, ExpandButtonView,
    expandFeature, HtmlRoot, HtmlRootView, labelEditUiModule, loadDefaultModules, LogLevel, overrideViewerOptions,
    PreRenderedElement, PreRenderedView, RectangularNodeView, SButton, SCompartment, SCompartmentView,
    SGraphView, SLabel, SLabelView, SModelRoot, TYPES
} from "sprotty";
import { OrmModelGraph, OrmModelNode, OrmModelRelationshipEdge } from "./model";
import { RelationshipEdgeView } from "./views";

const ormDiagramModule = new ContainerModule((bind, unbind, isBound, rebind) => {
    rebind(TYPES.ILogger).to(ConsoleLogger).inSingletonScope();
    rebind(TYPES.LogLevel).toConstantValue(LogLevel.log);
    // Router
    bind(LibavoidRouter).toSelf().inSingletonScope();
    bind(TYPES.IEdgeRouter).toService(LibavoidRouter);
    bind(TYPES.IAnchorComputer).to(LibavoidDiamondAnchor).inSingletonScope();
    bind(TYPES.IAnchorComputer).to(LibavoidEllipseAnchor).inSingletonScope();
    bind(TYPES.IAnchorComputer).to(LibavoidRectangleAnchor).inSingletonScope();

    // change animation speed to 300ms
    rebind(TYPES.CommandStackOptions).toConstantValue({
        defaultDuration: 300,
        undoHistoryLimit: 50
    });
    // Model element bindings
    const context = { bind, unbind, isBound, rebind };
    configureModelElement(context, 'graph', OrmModelGraph, SGraphView);

    // Nodes
    configureModelElement(context, 'node:entity', OrmModelNode, RectangularNodeView, { enable: [expandFeature] });
    configureModelElement(context, 'node:embeddable', OrmModelNode, RectangularNodeView, { enable: [expandFeature] });
    configureModelElement(context, 'node:relationship', OrmModelNode, DiamondNodeView);

    // Compartments
    configureModelElement(context, 'comp:element-header', SCompartment, SCompartmentView);
    configureModelElement(context, 'comp:attributes', SCompartment, SCompartmentView);
    configureModelElement(context, 'comp:attribute-row', SCompartment, SCompartmentView);

    // Edges
    configureModelElement(context, 'edge:relationship', OrmModelRelationshipEdge, RelationshipEdgeView, { disable: [editFeature] });

    // Labels
    configureModelElement(context, 'label:header', SLabel, SLabelView, { enable: [editLabelFeature] });
    configureModelElement(context, 'label:relationship', SLabel, SLabelView, { enable: [editLabelFeature] });
    configureModelElement(context, 'label:text', SLabel, SLabelView, { enable: [editLabelFeature] });
    configureModelElement(context, 'label:key', SLabel, SLabelView, { enable: [editLabelFeature] });
    configureModelElement(context, 'label:required', SLabel, SLabelView, { enable: [editLabelFeature] });

    // Additional Sprotty elements
    configureModelElement(context, 'html', HtmlRoot, HtmlRootView);
    configureModelElement(context, 'palette', SModelRoot, HtmlRootView);
    configureModelElement(context, 'pre-rendered', PreRenderedElement, PreRenderedView);
    configureModelElement(context, ExpandButtonHandler.TYPE, SButton, ExpandButtonView);
});

export function createOrmDiagramContainer(widgetId: string): Container {
    const container = new Container();
    loadDefaultModules(container, { exclude: [labelEditUiModule] });
    container.load(ormDiagramModule);
    overrideViewerOptions(container, {
        needsClientLayout: true,
        needsServerLayout: true,
        baseDiv: widgetId,
        hiddenDiv: widgetId + '_hidden',
        popupOpenDelay: 0
    });

    // Router options
    const router = container.get(LibavoidRouter);
    router.setOptions({
        routingType: RouteType.Orthogonal,
        segmentPenalty: 50,
        // at least height of label to avoid labels overlap if
        // there two neighbour edges have labels on the position
        idealNudgingDistance: 24,
        // 25 - height of label text + label offset. Such shape buffer distance is required to
        // avoid label over shape
        shapeBufferDistance: 25,
        nudgeOrthogonalSegmentsConnectedToShapes: true,
        // allow or disallow moving edge end from center
        nudgeOrthogonalTouchingColinearSegments: false,
    });

    return container;
}
