#include "rwmake.ch"

/*
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Adiciona botão na tela de pedido de compra            ¦
*/

USER FUNCTION MT121BRW()
	AAdd(aRotina,{"Imprimir Pedido","U_UMatr110(Alias(),Recno(),8)",0,6})
	AAdd(aRotina,{"Impr.Pedido Grafico","U_PEDCOM(Alias(),Recno(),8)",0,6})
   AAdd(aRotina,{"Questionar","U_PEDQUEST()",0,6})
   AAdd(aRotina,{"Seleciona Comprador","U_GETPICSC7()",0,6})
   AAdd(aRotina,{"Imprimir Novo Pedido","U_NEWPEDCOM()",0,6})
RETURN
