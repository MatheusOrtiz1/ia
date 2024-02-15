#include "totvs.ch"

/*/{Protheus.doc} EntidadePedidoDeVendaConasa
Calsse entidade de pedido de venda CONASA
@type class
@author Rodrigo Godinho
@since 14/08/2023
/*/
CLASS EntidadePedidoDeVendaConasa FROM LongNameClass
	DATA cNumPV
	DATA dDtEmissao
	DATA cCodCLie
	DATA cLojaClie
	DATA cIdZ29
	DATA cMsgNF
	DATA aItens

	METHOD New() CONSTRUCTOR
	METHOD AddItem(oItem)
ENDCLASS

/*/{Protheus.doc} EntidadePedidoDeVendaConasa::New
Construtor
@type method
@author Rodrigo Godinho
@since 14/08/2023
@return object, Instância da classe
/*/
METHOD New() CLASS EntidadePedidoDeVendaConasa
	::cNumPV := ""
	::dDtEmissao := CToD("")
	::cCodCLie := ""
	::cLojaClie := ""
	::cIdZ29 := ""
	::cMsgNF := ""
	::aItens := {}
Return

METHOD AddItem(oItem) CLASS EntidadePedidoDeVendaConasa
	If ValType(oItem) == "O"
		If ValType(::aItens) != "A"
			::aItens := {}
		EndIf
		aAdd(::aItens, oItem)
	EndIf
Return
