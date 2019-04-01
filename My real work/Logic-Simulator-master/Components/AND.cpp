#include "AND.h"

/* Constructor */
AND::AND(Output* pOut, const GraphicsInfo& gfxInfo, int fanOut) : LogicGate(pOut, gfxInfo, 2, fanOut) {
	mLabel = "AND";
}

/* Returns the input pin coordiantes of the gate according to its index */
void AND::GetInputPinCoordinates(int& x, int& y, int n) {
	x = mGfxInfo.x1 - UI.PinMargin;
	y = mGfxInfo.y1 + UI.PinMargin + UI.PinOffset * (n > 0 ? 2 : n);
}

/* Calculates the output of the AND gate */
void AND::Operate() {
	bool out = 1;

	for (int i = 0; i < mInputsCount; i++) {
		out = out && (mInputPins[i].GetStatus() == Status::HIGH ? 1 : 0);
	}

	mOutputPin.SetStatus(out ? Status::HIGH : Status::LOW);
}

/* Draws the AND gate */
void AND::Draw(Output* pOut) {
	if (!mDeleted) {
		pOut->DrawAND(mGfxInfo, mSelected);
	}
}

/* Saves the states of the component*/
void AND::Save(ofstream& file) {
	file << "AND "<< mLabel << " " << (mGfxInfo.x1 + mGfxInfo.x2) / 2 << " " << (mGfxInfo.y1 + mGfxInfo.y2) / 2 << endl;
}

/* Returns the Add-ActionType of the component */
ActionType AND::GetAddActionType() const {
	return ActionType::ADD_GATE_AND;
}