import { Container, ContainerModule } from "inversify";
import { LibavoidDiamondAnchor, LibavoidEllipseAnchor, LibavoidRectangleAnchor, LibavoidRouter, RouteType } from 'sprotty-routing-libavoid';
import 'sprotty/css/sprotty.css';
import 'sprotty/css/command-palette.css';
import '../css/diagram.css';


import { configureModelElement, ConsoleLogger, labelEditUiModule, loadDefaultModules, LogLevel, overrideViewerOptions, RectangularNodeView, SGraph, SGraphView, TYPES } from "sprotty";
import { EntityNode } from "./model";

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
    configureModelElement(context, 'graph', SGraph, SGraphView);
    // Nodes
    configureModelElement(context, 'node', EntityNode, RectangularNodeView);
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
