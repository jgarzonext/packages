--------------------------------------------------------
--  DDL for Package PK_FIS_MOD347
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PK_FIS_MOD347" AS

  -- Variables para el registro de tipo 0

  tr0_nnifpre		VARCHAR2(9) := 'A58774308';
  tr0_tnompre		VARCHAR2(40) := 'CAIXASABADELL VIDA SA';
  tr0_csiglas		VARCHAR2(2) := 'CL';
  tr0_tnomvia		VARCHAR2(20) := 'GRACIA';
  tr0_nnumvia		NUMBER(5) := 33;
  tr0_nnumesc		VARCHAR2(2) := '  ';
  tr0_nnumpis		VARCHAR2(2) := ' 1';
  tr0_nnumpue		VARCHAR2(2) := ' 2';
  tr0_cpostal		NUMBER(5) := 8201;
  tr0_tmunici		VARCHAR2(12) := 'SABADELL';
  tr0_cprovin		NUMBER(2) := 8;
  tr0_ntotdec		NUMBER(5) := 1;
  tr0_ntotper		NUMBER(9);
  tr0_ntelrel		NUMBER(9) := 937277183;
  tr0_tnomrel		VARCHAR(40) := 'XXXXX XXXXX XXX';

  -- Variables para el registro de tipo 1

  tr1_nnifdec		VARCHAR2(9) := 'A58774308';
  tr1_tnomdec		VARCHAR(40) := 'CAIXASABADELL VIDA SA';
  tr1_ntelrel		NUMBER(9) := 937277183;
  tr1_tnomrel		VARCHAR2(40) := 'XXXXX XXXXX XXX';
  tr1_njustif		NUMBER(13) := 0;
  tr1_cdeccom		VARCHAR2(1) := ' ';
  tr1_cdecsus		VARCHAR2(1) := ' ';
  tr1_njusant		NUMBER(13) := 0;
  tr1_ntotpos		NUMBER(9);
  tr1_itotoper		NUMBER(15);
  tr1_ntotinm       NUMBER(9);
  tr1_itotinm       NUMBER(15);
  -- Variables para el registro de tipo 2

  tr2_nnifdec		VARCHAR2(9);
  tr2_nnifper		VARCHAR2(9);
  tr2_nnifrep		VARCHAR2(9);
  tr2_tnomper		VARCHAR2(40);
  tr2_cprovin		NUMBER(2);
  tr2_cpais 		NUMBER(3);
  tr2_cclave        VARCHAR2(1);
  tr2_impoper		NUMBER(15);
  tr2_operseg		VARCHAR2(1);
  tr2_arrelon		VARCHAR2(1);

  nsfiscab          NUMBER(8);

  v_fin			BOOLEAN := FALSE;

  CURSOR c_MOD347 (nsfiscab NUMBER) IS
      SELECT NNIFDEC,NNIFPER,NNIFREP,TNOMPER,CPROVIN,CPAIS,CCLAVE,
	         TO_NUMBER(TO_CHAR(SUM(importe)*100,'999999999999')) importe
        FROM FIS_MOD347
       WHERE SFISCAB = NSFISCAB
	  GROUP BY NNIFDEC,NNIFPER,NNIFREP,TNOMPER,CPROVIN,CPAIS,CCLAVE;

  PROCEDURE carga_MOD347(psfiscab   IN NUMBER,
						 pleidos   OUT NUMBER,
						 pgrabad   OUT NUMBER,
						 prechaz   OUT NUMBER,
						 perror    OUT NUMBER);
  PROCEDURE inicializa ( psfiscab   IN NUMBER,
                         perror    OUT NUMBER);
  PROCEDURE borrar     ( psfiscab   IN NUMBER,
                         perror    OUT NUMBER);
  PROCEDURE obtener_datos_cab;
  PROCEDURE lee;
  FUNCTION fin RETURN BOOLEAN;

END Pk_Fis_Mod347;

 
 

/

  GRANT EXECUTE ON "AXIS"."PK_FIS_MOD347" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_FIS_MOD347" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_FIS_MOD347" TO "PROGRAMADORESCSI";
