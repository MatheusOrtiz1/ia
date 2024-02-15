#include "totvs.ch"

/*/{Protheus.doc} EntidadeItemPedidoDeVendaConasa
Classe de entidade de item de pedido de venda da CONASA
@type class
@author Rodrigo Godinho
@since 14/08/2023
/*/
CLASS EntidadeItemPedidoDeVendaConasa FROM LongNameClass
	DATA cCodProd
	DATA nQtdVend
	DATA nPrecoUnit

	METHOD New() CONSTRUCTOR
ENDCLASS

/*/{Protheus.doc} EntidadeItemPedidoDeVendaConasa::New
Construtor
@type method
@author Rodrigo Godinho
@since 14/08/2023
@return object, Instância da classe
/*/
METHOD New() CLASS EntidadeItemPedidoDeVendaConasa
	::cCodProd := ""
	::nQtdVend := 0
	::nPrecoUnit := 0
Return
