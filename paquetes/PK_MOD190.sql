--------------------------------------------------------
--  DDL for Package PK_MOD190
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PK_MOD190" AS
   -- Variables para el registro de tipo 0
   tr0_nejedec		NUMBER(4) := 2002;
   tr0_nnifpre		VARCHAR2(9) := 'A58774308';
   tr0_tnompre		VARCHAR2(40) := 'CAIXASABADELL VIDA SA';
   tr0_csiglas		VARCHAR2(2) := 'CL';
   tr0_tnomvia		VARCHAR2(20) := 'GRACIA';
   tr0_nnumvia		NUMBER(5) := 33;
   tr0_nnumesc		VARCHAR2(2) := '  ';
   tr0_nnumpis		VARCHAR2(2) := ' 1';
   tr0_nnumpue		VARCHAR2(2) := ' 2';
   tr0_cpostal		codpostal.cpostal%TYPE := '8201'; --3606 jdomingo 30/11/2007  canvi format codi postal
   tr0_tmunici		VARCHAR2(12) := 'SABADELL';
   tr0_cprovin		NUMBER(2) := 8;
   tr0_ntotret           NUMBER(5) := 1;
   tr0_ntotper		NUMBER(9);
   tr0_ntelrel		NUMBER(9) := 937277183;
   tr0_tnomrel		VARCHAR(40) := '';
   -- Variables para el registro de tipo 1
   tr1_nnifdec		VARCHAR2(9);
   tr1_tnomdec		VARCHAR(40) := '';
   tr1_ntelrel		NUMBER(9) := 937277183;
   tr1_tnomrel		VARCHAR2(40) := '';
   tr1_njustif		NUMBER(13) := 1893500020553;
   tr1_cdeccom		VARCHAR2(1) := ' ';
   tr1_cdecsus		VARCHAR2(1) := ' ';
   tr1_njusant		NUMBER(13) := 0;
   tr1_ntotper		NUMBER(15);
   tr1_csigper          VARCHAR2(1);
   tr1_itotper		NUMBER(15);
   tr1_itotret		NUMBER(15);
   -- Variables para el registro de tipo 2
   tr2_nnifdec		VARCHAR2(9);
   tr2_nnifper		VARCHAR2(9);
   tr2_nnifrep		VARCHAR2(9);
   tr2_tnomper		VARCHAR2(40);
   tr2_cprovin		NUMBER(2);
   tr2_csigper		VARCHAR2(1);
   tr2_iperint		NUMBER(15);
   tr2_iretenc		NUMBER(15);
   tr2_ireducc		NUMBER(15);
   tr2_idespeses        NUMBER(13);
   tr2_cceumel          NUMBER(1) := 0;
   tr2_anynacim         NUMBER(4);
   tr2_cdiscapa         NUMBER(1);
   tr2_csitfami         NUMBER(1);
   tr2_nnifconj         VARCHAR2(9);
   tr2_ndesmen25        VARCHAR2(8);
   tr2_ndesdisc         VARCHAR2(4);
   tr2_ntotdes          NUMBER(2);
   tr2_ipensconj        NUMBER(13);
   tr2_ianfills         NUMBER(13);
   tr2_ntotasc          NUMBER(2);
   tr2_nascdis          NUMBER(2);
   tr2_ndecdisen           NUMBER(4);
   pspersonp            NUMBER(10);
   pspersonr            NUMBER(10);
   ---
   v_fin                BOOLEAN := FALSE;
   v_nomesret           BOOLEAN := FALSE;
   ---
   anypet  NUMBER(4);
   npetic  NUMBER(4);
   retescollit VARCHAR2(14);
   retpers NUMBER(6);
   contador NUMBER(6) := 0;
   ---
   ---CURSOR PROVISIONAL FINS QUE ACALRIR COM ES DETERMINEN. POTSER CALDRA ANAR
   ---A PRODUCTES
   CURSOR C_RETENIDORS (retescollit VARCHAR2) IS
      SELECT A.SPERSON, B.NNUMNIF
      FROM FONPENSIONES A, PERSONAS B
      WHERE A.SPERSON = B.SPERSON
      AND B.NNUMNIF = NVL(RETESCOLLIT, B.NNUMNIF)
      AND B.NNUMNIF IN ('G59105544','G62611413','G62611397');
   ---
   CURSOR c_mod190 (anypet NUMBER, npetic NUMBER, retescollit VARCHAR2) IS
      SELECT SPERSONP, NNIFPER,
             SPERSONR, NNIFREP,
             TNOMPER, CPROVIN,
             DECODE (CSIGPER,'P',' ','N'), SUM(IPERCEP)*100, SUM(IRETENC)*100,
             SUM(IREDUCC)*100, SUM(IGASTOS)*100
      FROM FIS_MOD190
      WHERE nnifret = retescollit
      AND NANYO = anypet
      AND NNUMPET = npetic
      GROUP BY SPERSONP, NNIFPER, SPERSONR, NNIFREP,TNOMPER,CPROVIN,CSIGPER;
   ---
   PROCEDURE inicialitza (pany NUMBER, ppet NUMBER, pretescollit VARCHAR2);
   PROCEDURE genera_t_mod190(pany NUMBER, ppet NUMBER, pfiscalini IN NUMBER,
      pfiscalfin IN NUMBER);
   PROCEDURE obtener_datos_cab;
   PROCEDURE retenidors;
   FUNCTION nomesret RETURN BOOLEAN;
   PROCEDURE lee;
   FUNCTION fin RETURN BOOLEAN;
END Pk_Mod190;
 
 

/

  GRANT EXECUTE ON "AXIS"."PK_MOD190" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_MOD190" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_MOD190" TO "PROGRAMADORESCSI";
