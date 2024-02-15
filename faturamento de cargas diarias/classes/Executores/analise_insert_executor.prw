#include "totvs.ch"
#Include "fwmvcdef.ch"
#include "fatcargasdef.ch"

#define CLICK_OK 0
#define CLICK_CANCEL 1

/*/{Protheus.doc} AnaliseInsertExecutor
Classe executora da an�lise
@type class
@author Rodrigo Godinho
@since 07/08/2023
/*/
CLASS AnaliseInsertExecutor FROM LongNameClass
	METHOD New() CONSTRUCTOR
	METHOD Execute()
ENDCLASS

/*/{Protheus.doc} AnaliseInsertExecutor::New
Construtor
@type method
@author Rodrigo Godinho
@since 07/08/2023
@return object, Inst�ncia da classe
/*/
METHOD New() CLASS AnaliseInsertExecutor
Return

/*/{Protheus.doc} AnaliseInsertExecutor::Execute
M�todo execute
@type method
@author Rodrigo Godinho
@since 07/08/2023
/*/
METHOD Execute() CLASS AnaliseInsertExecutor
	Local aButtons	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Confirmar"},{.T.,"Cancelar"},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}}
	Local aArea		:= GetArea()
	Local aAreaZ35	:= Z35->(GetArea())
	Local nExecRet	:= 0

	If Z29->Z29_STATUS == STATUS_CARGA_RECEBIDA
		nExecRet := FWExecView('An�lise','CTRFATUR_ANALISE_INSERT', MODEL_OPERATION_INSERT, , , , ,aButtons )
		If nExecRet == CLICK_OK ;
			.And. (Z29->Z29_STATUS == STATUS_CARGA_ANALISE_APROVADA .Or. Z29->Z29_STATUS == STATUS_CARGA_ANALISE_APROVADA_COM_RESSALVA)
			U_ClassExec(RegistroMTRExecutor():New())
		EndIf
	Else
		Z35->(dbSetOrder(2))
		If Z35->(MSSeek( xFilial("Z35") + Z29->Z29_ID ))
			If FWAlertYesNo("An�lise j� realizada. Deseja visualizar a an�lise que foi realizada?", "An�lise de Carga de Efluente")
				FWExecView('An�lise','CTRFATUR_ANALISE_BASE', MODEL_OPERATION_VIEW, , , , ,aButtons )
			EndIf
		Else
			FWAlertWarning("A an�lise s� pode ser realizada em cargas com status 'RECEBIBA'.", "An�lise de Carga de Efluente")
		EndIf
	EndIf

	RestArea(aAreaZ35)
	RestArea(aArea)
Return
