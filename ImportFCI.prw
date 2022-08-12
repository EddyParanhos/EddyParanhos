#include 'protheus.ch'
#include 'parmtype.ch'
#include "rwmake.ch"  


/*--------------------------------------------------------------------*
| Func:  ImportFCI()                                                  |
| Autor: Edmar Paranhos                                               |
| Data:  26/05/2019                                                   |
| Desc:  Atualiza o campo D3_PERIMP (% de Importacao).                |
| Obs.:  Consulta o B1_ORIGEM - Besins - Gatilho SX7.                 |
*---------------------------------------------------------------------*/

/*
- Se a origem da mercadoria for 3-Nacional, importação superior a 40% e menor ou igual a 70%, considerar 50%.
- Se a origem da mercadoria for 5-Nacional, com conteúdo de importação igual ou inferior a 40%, considerar 40%.
- Se a origem da mercadoria for 8-Nacional, com conteúdo de importação superior a 70%, considerar 100%.
*/

User Function ImportFCI()

	Local cOrig   := ""
	Local nPerImp := 0

	IIf(inclui,'',POSICIONE("SB1",1,XFILIAL("SB1") + SB1->B1_COD,"B1_ORIGEM"))
	
	cOrig := SB1->B1_ORIGEM


	If cOrig == '3' 

		nPerImp := 50.00

	Endif

	If cOrig == '5'

		nPerImp := 40.00

	Endif

	If cOrig == '8'

		nPerImp := 100.00

	Endif

Return ( nPerImp )
