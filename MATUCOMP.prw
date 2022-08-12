#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "RWMAKE.CH"

/*---------------------------------------------------------------------*
| Func:  MATUCOMP()                                                   |
| Autor: Edmar Paranhos                                               |
| Data:  05/08/2019                                                   |
| Desc:  Alimenta tabelas de complementos.                            |
| Obs.: *MV_ATUCOMP = T         									   |
*---------------------------------------------------------------------*/


User Function MATUCOMP()

	Local Area := GetArea()
	Local AreaCD5 := CD5-> (GetArea())
	Local AreaSD1 := SD1-> (GetArea())
	Local cTipo   := ""
	Local cGrupo  := ""
	Local cNumDi  := ""
	Local oDlg
	Local oFont
	Local oFont1, oFont2
	Local oFolder
	Private lContinua:= .T.
	
	cEntSai := ParamIXB[1]
	cSerie  := ParamIXB[2]
	cDoc    := ParamIXB[3]
	cCliefor:= ParamIXB[4]
	cLoja   := ParamIXB[5]

	IIf(inclui,'',POSICIONE("SA2",1,XFILIAL("SA2") + SA2->A2_COD,"A2_TIPO"))
	cTipo := SA2->A2_TIPO

	If cTipo == "X"						

		CD5->(DbSetOrder(4))//CD5_FILIAL, CD5_DOC, CD5_SERIE, CD5_FORNEC, CD5_LOJA, CD5_ITEM, R_E_C_N_O_, D_E_L_E_T_

		If cEntSai == "E"
		
		//Tela para obter o numero da D.I / Valor da AFRMM e Imposto de Importação
		
	Define MSDialog oDlg Title "Gera Complementos NF-e" From 0,0 To 300,700 Pixel

	@05,010 Say "Nota Fiscal:" Pixel Of oDlg
	@05,030 Say nNumNf    Pixel Of oDlg
	@05,050 Say "-"   Pixel Of oDlg
	@05,080 Say "Serie:"  Pixel Of oDlg
	@05,110 Say nSerNf    Pixel Of oDlg

	//Dados da Fazenda.
	@030,010 Say "Numero D.I:" Pixel Of oDlg
	@029,050 MSGet cNumDi PICTURE "@!" Size 69,09 Of oDlg Pixel

	@070,140  BUTTON "Grava Numero D.I."  SIZE 55 ,15   	FONT oDlg:oFont  OF oDlg PIXEL Action (lContinua := .T.,ODlg:End()) Message "Clique aqui para Confirmar" Of oDlg

	Activate MSDialog oDlg Centered /*On Init EnchoiceBar(oDlg, {||u_OK(),oDlg:End()}, {||oDlg:End()},,aButtons)*/ Valid MsgYesNo("Confirma Numero D.I?")
	
//Return
		
			dbselectarea("SD1")
			dbsetorder(1)
			dbseek(xFilial("SD1")+cDoc+cSerie+cClieFor+cLoja)

			If SD1-> (DbSeek(xFilial("SD1") +SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
				While !SD1->(Eof()) .and. SD1->D1_DOC == SF1->F1_DOC .and. SD1->D1_SERIE == SF1->F1_SERIE;
				.and. SD1->D1_FORNECE == SF1->F1_FORNECE .and. SD1->D1_LOJA == SF1->F1_LOJA

					lExiste 	:= CD5->(dbSeek(xFilial("CD5")+cEntSai+cSerie+cDoc+cClieFor+cLoja))

					If lExiste
						RecLock("CD5",.F.)

					Else 
						RecLock("CD5",.T.)

						dbSelectArea("CD5")
						//Gera Complemento para todos os itens da NF	
						CD5->(dbSetOrder(1))
						CD5->CD5_FILIAL	:= xFilial("CD5")
						CD5->CD5_ITEM	:= SD1->D1_ITEM
						CD5->CD5_DOC	:= cDoc
						CD5->CD5_SERIE	:= cSerie
						CD5->CD5_FORNEC	:= cClieFor
						CD5->CD5_LOJA	:= cLoja
						CD5->CD5_TPIMP  := "0"
						CD5->CD5_DOCIMP	:= cNumDi
						CD5->CD5_NDI	:= cNumDi
						CD5->CD5_BSPIS	:= SD1->D1_BASIMP6
						CD5->CD5_ALPIS	:= SD1->D1_ALQIMP6
						CD5->CD5_VLPIS	:= SD1->D1_VALIMP6
						CD5->CD5_BSCOF	:= SD1->D1_BASIMP5
						CD5->CD5_ALCOF	:= SD1->D1_ALQIMP5
						CD5->CD5_VLCOF	:= SD1->D1_VALIMP5
						CD5->CD5_LOCDES	:= "SAO PAULO"
						CD5->CD5_UFDES	:= "SP"
						CD5->CD5_DTDI	:= SD1->D1_EMISSAO
						CD5->CD5_DTDES	:= SD1->D1_EMISSAO
						CD5->CD5_LOCAL	:= "0"
						CD5->CD5_NADIC	:= Substr(SD1->D1_ITEM,2,3)
						CD5->CD5_SQADIC	:= Substr(SD1->D1_ITEM,2,3)
						CD5->CD5_CODFAB	:= cCliefor
						CD5->CD5_LOJFAB := cLoja			
						CD5->CD5_VLRII	:= SD1->D1_II
						CD5->CD5_CODEXP	:= cCliefor
						CD5->CD5_LOJEXP := cLoja  
						CD5->CD5_VTRANS	:= "1"
						CD5->CD5_VAFRMM	:= 0
						CD5->CD5_INTERM	:= "1"


						CD5->(MsUnlock())

					EndIf

					SD1->(DbSkip())

				Enddo
			EndIf
		Endif 
	Endif

	RestArea(Area)
	CD5->(RestArea(AreaCD5))
	SD1->(RestArea(AreaSD1))

Return