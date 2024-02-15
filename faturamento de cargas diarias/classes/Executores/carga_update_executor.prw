#include "totvs.ch"
#Include "fwmvcdef.ch"
#include "fatcargasdef.ch"

Static aStNoUpd	:= { 	STATUS_CARGA_PEDIDO_EMITIDO, ;
						STATUS_CARGA_FATURADA }

/*/{Protheus.doc} CargaUpdateExecutor
Classe executora de alteração de carga
@type class
@author Rodrigo Godinho
@since 31/08/2023
/*/
CLASS CargaUpdateExecutor FROM LongNameClass
	METHOD New() CONSTRUCTOR
	METHOD Execute()
ENDCLASS

/*/{Protheus.doc} CargaUpdateExecutor::New
Construtor
@type method
@author Rodrigo Godinho
@since 31/08/2023
@return object, Instância da classe
/*/
METHOD New() CLASS CargaUpdateExecutor
Return

/*/{Protheus.doc} CargaUpdateExecutor::Execute
Método execute
@type method
@author Rodrigo Godinho
@since 31/08/2023
/*/
METHOD Execute() CLASS CargaUpdateExecutor
	Local aButtons	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Confirmar"},{.T.,"Cancelar"},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}}
	Local nPosStNoUpd	:= 0

	If (nPosStNoUpd := aScan(aStNoUpd, {|x| AllTrim(x) == AllTrim(Z29->Z29_STATUS)})) == 0
		FWExecView('Alteração','CTRFATUR', MODEL_OPERATION_UPDATE, , {|| .T.}, , ,aButtons )
	Else
		FWAlertWarning("O status atual da carga não permite alteração.", "Alteração")
	EndIf

Return
