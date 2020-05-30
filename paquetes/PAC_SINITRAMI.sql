--------------------------------------------------------
--  DDL for Package PAC_SINITRAMI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_SINITRAMI" authid current_user IS
/***************************************************************
	PAC_SINITRAMI: Especificación del paquete de las funciones
		para los triggers de actualización de las
                tablas de siniestros a partir de las de
                tramitaciones

***************************************************************/
-- Data impossible cap endavant
ultima_data DATE := TO_DATE('1/1/3000');
-- Data impossible cap endarrera
primera_data DATE := TO_DATE('1/1/900');
FUNCTION f_admet_pagaments ( p_nsinies IN NUMBER, p_ntramit IN NUMBER, p_sperson IN NUMBER, p_ctipdes IN NUMBER, p_cpagdes IN NUMBER )
  RETURN NUMBER;
FUNCTION f_destinatrami_repetit ( p_nsinies IN NUMBER, p_ntramit IN NUMBER, p_sperson IN NUMBER, p_ctipdes IN NUMBER )
  RETURN NUMBER;
FUNCTION f_primera_activitat ( p_nsinies IN NUMBER,  P_NTRAMIT IN NUMBER, p_sperson IN NUMBER, p_ctipdes IN NUMBER )
  RETURN VARCHAR2;
FUNCTION f_primera_referencia ( p_nsinies IN NUMBER, P_NTRAMIT IN NUMBER, p_sperson IN NUMBER, p_ctipdes IN NUMBER, p_crefsin IN VARCHAR2 )
  RETURN VARCHAR2;
PROCEDURE f_calcular_valors ( p_sidepag IN NUMBER );
PROCEDURE f_calcular_valors_del_garan ( p_sidepag IN NUMBER );
FUNCTION f_comprobacio_pagaments ( p_sidepag IN NUMBER )
  RETURN NUMBER;
FUNCTION f_ultimo_importe (pnsinies IN NUMBER, pcgarant IN NUMBER, piultimo OUT NUMBER)
  RETURN NUMBER;
FUNCTION f_tnou_iant (pnsinies IN NUMBER,pntramit IN NUMBER,pcgarant IN NUMBER, iant OUT NUMBER, tnou OUT NUMBER)
  RETURN NUMBER;
FUNCTION f_inou (pnsinies IN NUMBER, pntramit IN NUMBER, pcgarant IN NUMBER, tnou IN NUMBER,inou OUT NUMBER)
  RETURN NUMBER;
FUNCTION f_ins_valorasini (pnsinies IN NUMBER, pntramit IN NUMBER, pcgarant IN NUMBER, pfvalora IN DATE, pivalora IN NUMBER)
  RETURN NUMBER;
FUNCTION f_ins_destinatarios (pnsinies IN NUMBER,
                              pntramit IN NUMBER,
                              psperson IN NUMBER,
                              pctipdes IN NUMBER,
                              pcpagdes IN NUMBER,
                              pcactpro IN NUMBER,
                              pcrefsin IN VARCHAR2)
    RETURN NUMBER;
FUNCTION f_act_destinatarios (pnsinies IN NUMBER,
                              pntramit IN NUMBER,
                              psperson IN NUMBER,
                              pctipdes IN NUMBER,
                              pcpagdes IN NUMBER,
                              pcactpro IN NUMBER,
                              pcrefsin IN VARCHAR2)
  RETURN NUMBER;
FUNCTION f_del_destinatarios (pnsinies IN NUMBER,
                              pntramit IN NUMBER,
                              psperson IN NUMBER,
                              pctipdes IN NUMBER,
                              pcpagdes IN NUMBER,
                              pcactpro IN NUMBER,
                              pcrefsin IN VARCHAR2)
  RETURN NUMBER;
END pac_sinitrami;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_SINITRAMI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SINITRAMI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SINITRAMI" TO "PROGRAMADORESCSI";
