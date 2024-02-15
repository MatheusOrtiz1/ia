#include "rwmake.ch"
#include "topconn.ch"
#INCLUDE "protheus.ch"
User function A410CONS()

	//ações relacionadas dentro da alteração do pedido de venda!
	_abb := {}       

	if inclui .or. altera
		AAdd(_abb, {"Itens Garantia(F5)" , { || U_Z23PEDIDO() }, "Itens Garantia(F5)"    })
	endif

	SetKey(VK_F5, {|| U_Z23PEDIDO()})

return(_abb)
