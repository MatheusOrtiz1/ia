#include "totvs.ch"
#Include "fwmvcdef.ch"
#include "fatcargasdef.ch"

Static aStNoUpd	:= { 	STATUS_CARGA_PEDIDO_EMITIDO, ;
						STATUS_CARGA_FATURADA }

/*/{Protheus.doc} CargaDeleteExecutor
Classe executora de exclus�o de carga
@type class
@author Rodrigo Godinho
@since 31/08/2023
/*/
CLASS CargaDeleteExecutor FROM LongNameClass
	METHOD New() CONSTRUCTOR
	METHOD Execute()
ENDCLASS

/*/{Protheus.doc} CargaDeleteExecutor::New
Construtor
@type method
@author Rodrigo Godinho
@since 31/08/2023
@return object, Inst�ncia da classe
/*/
METHOD New() CLASS CargaDeleteExecutor
Return

/*/{Protheus.doc} CargaDeleteExecutor::Execute
M�todo execute
@type method
@author Rodrigo Godinho
@since 31/08/2023
/*/
METHOD Execute() CLASS CargaDeleteExecutor
	Local aButtons	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Confirmar"},{.T.,"Cancelar"},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}}
	Local nPosStNoUpd	:= 0

	If (nPosStNoUpd := aScan(aStNoUpd, {|x| AllTrim(x) == AllTrim(Z29->Z29_STATUS)})) == 0
		FWExecView('Exclus�o','CTRFATUR', MODEL_OPERATION_DELETE, , {|| .T.}, , ,aButtons )
	Else
		FWAlertWarning("O status atual da carga n�o permite exclus�o.", "Exclus�o")
	EndIf

Return
