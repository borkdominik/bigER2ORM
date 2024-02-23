import { Container, ContainerModule } from "inversify";
// import { LibavoidDiamondAnchor, LibavoidEdge, LibavoidEllipseAnchor, LibavoidRectangleAnchor, LibavoidRouter, RouteType } from 'sprotty-routing-libavoid';
import 'sprotty/css/command-palette.css';
import 'sprotty/css/sprotty.css';
import '../css/diagram.css';
import {
    configureActionHandler,
    configureModelElement, ConsoleLogger, DiamondNodeView, editFeature, editLabelFeature, ExpandButtonHandler, ExpandButtonView,
    expandFeature, HtmlRootImpl, HtmlRootView, labelEditUiModule, loadDefaultModules, LogLevel, overrideViewerOptions,
    PreRenderedElementImpl,
    PreRenderedView, RectangularNodeView, SButtonImpl, SCompartmentImpl, SCompartmentView, SEdgeImpl, SLabelImpl, SLabelView, SModelRootImpl, SPortImpl, TYPES
} from "sprotty";
import { OrmModelGraph, OrmModelNode, OrmModelRelationshipEdge } from "./model";
import { InheritanceEdgeView, OrmModelView, RelationshipEdgeView, TriangleButtonView } from "./views";
import { RefreshAction, RefreshActionHandler } from "./refresh";
import toolbarModule from "./toolbar/di.config";

const diagramModule = new ContainerModule((bind, unbind, isBound, rebind) => {
    rebind(TYPES.ILogger).to(ConsoleLogger).inSingletonScope();
    rebind(TYPES.LogLevel).toConstantValue(LogLevel.log);
    // Router
    // bind(LibavoidRouter).toSelf().inSingletonScope();
    // bind(TYPES.IEdgeRouter).toService(LibavoidRouter);
    // bind(TYPES.IAnchorComputer).to(LibavoidDiamondAnchor).inSingletonScope();
    // bind(TYPES.IAnchorComputer).to(LibavoidEllipseAnchor).inSingletonScope();
    // bind(TYPES.IAnchorComputer).to(LibavoidRectangleAnchor).inSingletonScope();

    // change animation speed to 300ms
    rebind(TYPES.CommandStackOptions).toConstantValue({
        defaultDuration: 300,
        undoHistoryLimit: 50
    });
    // Model element bindings
    const context = { bind, unbind, isBound, rebind };
    configureModelElement(context, 'graph', OrmModelGraph, OrmModelView);

    // Nodes
    configureModelElement(context, 'node:inheritable', OrmModelNode, RectangularNodeView, { enable: [expandFeature] });
    configureModelElement(context, 'node:embeddable', OrmModelNode, RectangularNodeView, { enable: [expandFeature] });
    configureModelElement(context, 'node:relationship', OrmModelNode, DiamondNodeView);

    // Compartments
    configureModelElement(context, 'comp:element-header', SCompartmentImpl, SCompartmentView);
    configureModelElement(context, 'comp:attributes', SCompartmentImpl, SCompartmentView);
    configureModelElement(context, 'comp:attribute-row', SCompartmentImpl, SCompartmentView);

    // Edges
    configureModelElement(context, 'edge:relationship', OrmModelRelationshipEdge, RelationshipEdgeView, { disable: [editFeature] });
    configureModelElement(context, 'edge:inheritance', SEdgeImpl, InheritanceEdgeView, { disable: [editFeature] });

    // Edges
    configureModelElement(context, 'port', SPortImpl, TriangleButtonView);

    // Labels
    configureModelElement(context, 'label:header', SLabelImpl, SLabelView, { enable: [editLabelFeature] });
    configureModelElement(context, 'label:relationship', SLabelImpl, SLabelView, { enable: [editLabelFeature] });
    configureModelElement(context, 'label:text', SLabelImpl, SLabelView, { enable: [editLabelFeature] });
    configureModelElement(context, 'label:key', SLabelImpl, SLabelView, { enable: [editLabelFeature] });
    configureModelElement(context, 'label:required', SLabelImpl, SLabelView, { enable: [editLabelFeature] });

    // Additional Sprotty elements
    configureModelElement(context, 'html', HtmlRootImpl, HtmlRootView);
    configureModelElement(context, 'palette', SModelRootImpl, HtmlRootView);
    configureModelElement(context, 'pre-rendered', PreRenderedElementImpl, PreRenderedView);
    configureModelElement(context, ExpandButtonHandler.TYPE, SButtonImpl, ExpandButtonView);

    // Action Handlers
    configureActionHandler(context, RefreshAction.KIND, RefreshActionHandler);
});

export function createDiagramContainer(widgetId: string): Container {
    const container = new Container();
    loadDefaultModules(container, { exclude: [labelEditUiModule] });
    container.load(diagramModule);
    container.load(toolbarModule);
    overrideViewerOptions(container, {
        needsClientLayout: true,
        needsServerLayout: true,
        baseDiv: widgetId,
        hiddenDiv: widgetId + '_hidden',
        popupOpenDelay: 0
    });

    // // Router options
    // const router = container.get(LibavoidRouter);
    // router.setOptions({
    //     routingType: RouteType.Orthogonal,
    //     segmentPenalty: 50,
    //     // at least height of label to avoid labels overlap if
    //     // there two neighbour edges have labels on the position
    //     idealNudgingDistance: 24,
    //     // 25 - height of label text + label offset. Such shape buffer distance is required to
    //     // avoid label over shape
    //     shapeBufferDistance: 25,
    //     nudgeOrthogonalSegmentsConnectedToShapes: true,
    //     // allow or disallow moving edge end from center
    //     nudgeOrthogonalTouchingColinearSegments: false,
    // });

    return container;
}
