#pragma once
#include "..\Utilities\Defs.h"
#include "..\GUI\Output.h"
#include <fstream>
/*
	Base abstract class for all components: Gate, Switch, Connection and LED.
*/
class Component
{
protected:
	bool mSelected;			// Whether this component is selected or not
	bool mDeleted;			// Whether this component is deleted or not, needed for UNDO & REDO actions
	string mLabel;			// The component's label (title)
	GraphicsInfo mGfxInfo;	// The parameters (coordinates) required to draw a component

public:
	/* Constructor */
	Component();

	/* Constructor */
	Component(const GraphicsInfo& gfxInfo);

	/* Sets the selection of the component */
	void SetSelected(bool s);

	/* Returns whether the component is selected or not */
	bool IsSelected() const;

	/* Returns whether the component is deleted or not */
	bool IsDeleted() const;

	/* Sets the label of the component */
	void SetLabel(const string& label);

	/* Returns the label of the component */
	string GetLabel() const;

	/* Returns the bound coordinates of the component */
	GraphicsInfo GetGraphicsInfo() const;

	/* Sets the status of the input pin number n (0-indexed), to be used by connection class */
	virtual void SetInputPinStatus(int n, Status s) = 0;

	/* Returns the status of the input pin number n (0-indexed), if Switch returns -1 */
	virtual int GetInputPinStatus(int n) const = 0;

	/* Returns the status of the output pin, if LED returns -1 */
	virtual int GetOutputPinStatus() const = 0;

	/* Returns next connected */
	virtual Component* GetNextComponent(int index) = 0;

	/* Returns number of connected components */
	virtual int GetConnectedCount() = 0;
	
	/* Calculates the output according to the inputs */
	virtual void Operate() = 0;

	/* Draws the component */
	virtual void Draw(Output* pOut) = 0;

	/* Selects the component */
	virtual void Select();

	/* Deletes the component */
	virtual void Delete(Output* pOut) = 0;

	/* Restores the component after being deleted */
	virtual void Restore(Output* pOut) = 0;

	/* Saves the states of the component */
	virtual void Save(ofstream& file) = 0;

	/* Returns the Add-ActionType of the component */
	virtual ActionType GetAddActionType() const = 0;

	/* Destructor */
	virtual ~Component();
};