const MY_WORKCHAIN = BASECHAIN;
const OP_MINT = stringCrc32("mint"); // 1c28e4aa
const OP_BURN = stringCrc32("burn"); // b4aa8123

var supply: int = 0;

fun mintTokens(amount: int) {
    supply += amount;
}

fun burnTokens(amount: int) {
    assert(supply >= amount) throw 1004;
    supply -= amount;
}

fun routeInternal(`ctx::sender`: slice, `ctx::value`: int, `ctx::fwd_fee`: int, `ctx::body`: slice) {
    var (op: int, _) = `ctx::body`.loadOpAndQueryId();

    if (op == OP_MINT) {
        mintTokens(100);
        return;
    }

    if (op == OP_BURN) {
        burnTokens(50);
        return;
    }

    throw 0xffff;
}

fun main(`ctx::value`: int, inMsgFull: cell, `ctx::body`: slice) {
    var s = inMsgFull.beginParse();
    var flags = s.loadMsgFlags();
    if (isBounced(flags)) { return; }

    var (`ctx::sender`: slice, `ctx::fwd_fee`: int) = s.retrieveCtx(MY_WORKCHAIN);
    routeInternal(`ctx::sender`, `ctx::value`, `ctx::fwd_fee`, `ctx::body`);
}
