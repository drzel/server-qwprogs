float (entity obj, entity builder) CheckArea = {
    vector start, end;
    start = obj.origin;
    end = start;
    tracebox(start, obj.mins, obj.maxs, end, MOVE_NORMAL, builder);

    if (trace_inopen) {
        return (1);
    } else {
        return (0);
    }
};
