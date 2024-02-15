#include "totvs.ch"
#Include "fwmvcdef.ch"

#define CLICK_OK 0
#define CLICK_CANCEL 1

/*/{Protheus.doc} CargaInsertExecutor
Classe executora de criação de carga
@type class
@author Rodrigo Godinho
@since 10/08/2023
/*/
CLASS CargaInsertExecutor FROM LongNameClass
	METHOD New() CONSTRUCTOR
	METHOD Execute()
ENDCLASS

/*/{Protheus.doc} CargaInsertExecutor::New
Construtor
@type method
@author Rodrigo Godinho
@since 10/08/2023
@return object, Instância da classe
/*/
METHOD New() CLASS CargaInsertExecutor
Return

/*/{Protheus.doc} CargaInsertExecutor::Execute
Método execute
@type method
@author Rodrigo Godinho
@since 10/08/2023
/*/
METHOD Execute() CLASS CargaInsertExecutor
	Local aButtons	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Confirmar"},{.T.,"Cancelar"},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}}
	Local nExecRet	:= 0

	nExecRet := FWExecView('Inclusão','CTRFATUR', MODEL_OPERATION_INSERT, , {|| .T.}, , ,aButtons )
	If nExecRet == CLICK_OK
		U_ClassExec(AnaliseInsertExecutor():New())
	EndIf
Return
