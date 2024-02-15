#include "totvs.ch"
#Include "fwmvcdef.ch"
#include "fatcargasdef.ch"

Static aStNoCanc	:= { 	STATUS_CARGA_ANALISE_REPROVADA, ;
							STATUS_CARGA_CANCELADA_CLIENTE, ;
							STATUS_CARGA_PEDIDO_EMITIDO, ;
							STATUS_CARGA_FATURADA }

/*/{Protheus.doc} CanceladoClienteExecutor
Classe executora de cancelamento de cliente
@type class
@author Rodrigo Godinho
@since 11/08/2023
/*/
CLASS CanceladoClienteExecutor FROM LongNameClass
	METHOD New() CONSTRUCTOR
	METHOD Execute()
ENDCLASS

/*/{Protheus.doc} CanceladoClienteExecutor::New
Construtor
@type method
@author Rodrigo Godinho
@since 11/08/2023
@return object, Instância da classe
/*/
METHOD New() CLASS CanceladoClienteExecutor
Return

/*/{Protheus.doc} CanceladoClienteExecutor::Execute
Método execute
@type method
@author Rodrigo Godinho
@since 11/08/2023
/*/
METHOD Execute() CLASS CanceladoClienteExecutor
	Local aButtons		:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Confirmar Canc."},{.T.,"Voltar"},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}}
	Local aArea			:= GetArea()
	Local nPosStNoCanc	:= 0
	
	If (nPosStNoCanc := aScan(aStNoCanc, {|x| AllTrim(x) == AllTrim(Z29->Z29_STATUS)})) == 0
		FWExecView('Cancelado pelo Cliente','CTRFATUR_CANCELADO_CLIENTE', MODEL_OPERATION_UPDATE, , , , , aButtons )
	Else
		FWAlertWarning("O status atual da carga não permite o cancelamento da carga.", "Cancelado pelo cliente")
	EndIf

	RestArea(aArea)
Return
