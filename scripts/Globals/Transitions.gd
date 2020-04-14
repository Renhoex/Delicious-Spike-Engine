extends Node

const TRANS_NONE = 0;
const TRANS_POSECHANGE = 1;
const TRANS_RELOAD = 2;
const TRANS_AUTO_SAVE = 3;

var transPointID = 0;
var transType = TRANS_NONE;
var transMapID = 0;
var warpIndex = -1;
var warpPos = Vector2.ZERO;
