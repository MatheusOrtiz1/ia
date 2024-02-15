#include "totvs.ch"
#Include "fwmvcdef.ch"
#include "fatcargasdef.ch"

/*/{Protheus.doc} BaixaMTRExecutor
Classe executora de Baixa MTR
@type class
@author Rodrigo Godinho
@since 14/08/2023
/*/
CLASS BaixaMTRExecutor FROM LongNameClass
	METHOD New() CONSTRUCTOR
	METHOD Execute()
ENDCLASS

/*/{Protheus.doc} BaixaMTRExecutor::New
Construtor
@type method
@author Rodrigo Godinho
@since 14/08/2023
@return object, Instância da classe
/*/
METHOD New() CLASS BaixaMTRExecutor
Return

/*/{Protheus.doc} BaixaMTRExecutor::Execute
Método execute
@type method
@author Rodrigo Godinho
@since 14/08/2023
/*/
METHOD Execute() CLASS BaixaMTRExecutor
	Local aButtons	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Confirmar"},{.T.,"Cancelar"},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}}
	Local aArea		:= GetArea()

	If Z29->Z29_STATUS == STATUS_CARGA_REGISTRO_MTR
		FWExecView('Baixa de MTR','CTRFATUR_BAIXA_MTR', MODEL_OPERATION_UPDATE, , , , 60, aButtons )
	Else
		FWAlertWarning("A Baixa de MTR só pode ser realizada em cargas com status 'MTR Registrador'.", "Baixa de MTR")
	EndIf

	RestArea(aArea)
Return
