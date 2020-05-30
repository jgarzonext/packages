--------------------------------------------------------
--  DDL for Package Body PK_MOD190
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PK_MOD190" AS
---
---
PROCEDURE inicialitza (pany NUMBER, ppet NUMBER, pretescollit VARCHAR2) IS
BEGIN
   anypet := pany;
   npetic := ppet;
   IF pretescollit IS NOT NULL THEN
      retescollit := pretescollit;
   ELSE
      retescollit := NULL;
   END IF;
END INICIALITZA;
---
---
PROCEDURE genera_t_mod190 (pany NUMBER, ppet NUMBER, pfiscalini IN NUMBER,
      pfiscalfin IN NUMBER) IS
   XNNIFPER VARCHAR2(14);
   XNNIFREP VARCHAR2(14);
   XTNOMPER VARCHAR2(40);
   CURSOR C (ppet IN NUMBER, anypet IN NUMBER) IS
      SELECT *
      FROM FIS_MOD190
      WHERE NNUMPET = ppet
      AND NANYO = anypet
      FOR UPDATE OF NNIFPER, NNIFREP, TNOMPER;
BEGIN
   DELETE FIS_MOD190
   WHERE NNUMPET = ppet
   AND NANYO = pany;
   COMMIT;
   ---
   INSERT INTO FIS_MOD190 (
      NANYO, NNUMPET, CRAMO,
      CMODALI, CTIPSEG, CCOLECT,
      CTIPO, NNIFRET, SPERSONP,
      NNIFPER, SPERSONR, NNIFREP,
      TNOMPER, CPROVIN, CSIGPER,
      IPERCEP, PRETENC, IRETENC,
      IREDUCC, IGASTOS, CERROR)
   SELECT SUBSTR(PFISCAL,1,4), NNUMPET, CRAMO,
          CMODALI, CTIPSEG, CCOLECT,
          190, NULL, SPERSONP,
          NNUMNIFP, SPERSON1, NNUMNIF1,
          NULL, CPROVIN, CSIGBASE,
          IBRUTO, PRETENC, IRETENC,
          IRESRED, 0, 0
   FROM FIS_DETCIERREPAGO
   WHERE csubtipo = 190
   AND nnumpet = ppet
   AND pfiscal BETWEEN pfiscalini AND pfiscalfin;
   COMMIT;
   FOR REG IN C(ppet, pany) LOOP
      XNNIFPER := NULL;
      XNNIFREP := NULL;
      -- Nif del Perceptor
      IF reg.NNIFREP IS NOT NULL THEN -- Si es menor El Nif del perceptor va en blanco.
         XNNIFPER := NULL;
         XNNIFREP := PK_FIS_HACIENDA.DNI_POS(reg.NNIFREP);
      ELSE
         XNNIFPER := PK_FIS_HACIENDA.DNI_POS(reg.NNIFPER);
         XNNIFREP := NULL;
      END IF;
      -- Nombre del Perceptor
      BEGIN
         SELECT SUBSTR(TRIM(TAPELLI)||' '||TRIM(TNOMBRE),1,40)
         INTO XTNOMPER
         FROM PERSONAS
         WHERE SPERSON = reg.SPERSONP;
      EXCEPTION
         WHEN OTHERS THEN
      	    XTNOMPER := NULL;
      END;
      xtnomper := REPLACE(REPLACE(REPLACE(REPLACE(
      	REPLACE(REPLACE(REPLACE(UPPER(xtnomper),'.',' '),'0','O'),
        '  ',' '),'ª',' '),'  ',' '),'#','Ñ'),'Á','A');
      IF REG.CPROVIN IS NULL THEN
         REG.CPROVIN := 8;
      END IF;
      UPDATE FIS_MOD190
      SET TNOMPER = XTNOMPER,
          NNIFPER = XNNIFPER, NNIFREP = XNNIFREP,
          CPROVIN = REG.CPROVIN
      WHERE CURRENT OF C;
   END LOOP;
   COMMIT;
   FOR reg IN (SELECT cramo,cmodali,ctipseg, ccolect, sproduc
               FROM PRODUCTOS
               WHERE cramo = 1
               AND cmodali = 1
               AND ctipseg > 0
               AND ccolect = 0)
   LOOP
      UPDATE fis_mod190
      SET nnifret = (SELECT PK_FIS_HACIENDA.DNI_POS(a.NNUMNIF)
                     FROM PERSONAS a, FONPENSIONES b, PLANPENSIONES c, PROPLAPEN d
                     WHERE d.sproduc = reg.sproduc
                     AND c.ccodpla = d.ccodpla
                     AND b.ccodfon = c.ccodfon
                     AND a.sperson = b.sperson)
      WHERE fis_mod190.cramo = reg.cramo
      AND fis_mod190.cmodali = reg.cmodali
      AND fis_mod190.ctipseg = reg.ctipseg
      AND fis_mod190.ccolect = reg.ccolect;
   END LOOP;
   COMMIT;
EXCEPTION
   WHEN OTHERS THEN
      PK_ENV_COMU.traza(PK_AUTOM.trazas, pk_autom.depurar, 'Error inesperado en GENERA_T_MOD190. '||SQLERRM);
--      dbms_output.put_line('Error inesperado en GENERA_T_MOD190. '||SQLERRM);
END genera_t_mod190;
---
---
PROCEDURE obtener_datos_cab IS
   XTNOMRET VARCHAR2(40);
BEGIN
   tr0_ntotret := 0;
   SELECT COUNT(1)
   INTO tr0_ntotret
   FROM FONPENSIONES A, PERSONAS B
   WHERE A.SPERSON = B.SPERSON
   AND B.NNUMNIF = NVL(RETESCOLLIT, B.NNUMNIF)
   AND B.NNUMNIF IN ('G59105544','G62611413','G62611397');
   ---
   tr0_ntotper := 0;
   SELECT COUNT(1)
   INTO tr0_ntotper
   FROM (
      SELECT 1
      FROM FIS_MOD190
      WHERE nnifret = NVL(retescollit, nnifret)
      AND NANYO = anypet
      AND NNUMPET = npetic
      GROUP BY SPERSONP, NNIFPER, SPERSONR, NNIFREP,TNOMPER,CPROVIN,CSIGPER,NNIFRET
      );
--   dbms_output.put_line('TOTAL OPERACIONS: '||TR0_NTOTPER);
EXCEPTION
   WHEN OTHERS THEN
      PK_ENV_COMU.traza(PK_AUTOM.trazas, pk_autom.depurar, 'Error inesperado en OBTENER_DATOS_CAB. 0 '||SQLERRM);
--      dbms_output.put_line('Error inesperado en OBTENER_DATOS_CAB. 0 '||SQLERRM);
END obtener_datos_cab;
---
---
PROCEDURE retenidors IS
   XTNOMRET VARCHAR2(40);
BEGIN
   IF NOT c_retenidors%ISOPEN THEN
     OPEN c_retenidors(retescollit);
   END IF;
   ---Si ja haviem escollit un únic retenidor troba aquell
   ---Si no n'hem escollit cap anirà actualitzant les variables globals
   FETCH c_retenidors
    INTO retpers, retescollit;
   IF c_retenidors%NOTFOUND THEN
      v_nomesret := TRUE;
      v_fin := TRUE;
      CLOSE c_retenidors;
   ELSE
      v_fin := FALSE;
      tr1_ntotper := 0;
      SELECT COUNT(1)
      INTO tr1_ntotper
      FROM (
         SELECT 1
         FROM FIS_MOD190
         WHERE nnifret = retescollit
         AND NANYO = anypet
         AND NNUMPET = npetic
         GROUP BY SPERSONP, NNIFPER, SPERSONR, NNIFREP,TNOMPER,CPROVIN, CSIGPER
         );
      SELECT SUM(DECODE(csigper,'N',-ipercep,ipercep))*100,SUM(IRETENC)*100
      INTO tr1_itotper, tr1_itotret
      FROM FIS_MOD190
      WHERE nnifret = retescollit
      AND NANYO = anypet
      AND NNUMPET = npetic;
      IF tr1_itotper < 0 THEN
         tr1_itotper := tr1_itotper * -1;
         tr1_csigper := 'N';
      ELSE
         tr1_csigper := ' ';
      END IF;
      tr1_nnifdec := retescollit;
      -- Nom del Retenidor
      BEGIN
         SELECT SUBSTR(TRIM(TAPELLI)||' '||TRIM(TNOMBRE),1,40)
         INTO XTNOMRET
         FROM PERSONAS
         WHERE SPERSON = retpers;
      EXCEPTION
         WHEN OTHERS THEN
      	    XTNOMRET := NULL;
      END;
      tr1_tnomdec := REPLACE(REPLACE(REPLACE(REPLACE(
      	REPLACE(REPLACE(REPLACE(xtnomret,'.',' '),'0','O'),
        '  ',' '),'ª',' '),'  ',' '),'#','Ñ'),'Á','A');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      PK_ENV_COMU.traza(PK_AUTOM.trazas, pk_autom.depurar, 'Error inesperado en RETENIDORS. '||SQLERRM);
--      dbms_output.put_line('Error inesperado en RETENIDORS. '||SQLERRM);
END retenidors;
---
---
FUNCTION nomesret RETURN BOOLEAN IS
BEGIN
   RETURN v_nomesret;
END nomesret;
---
---
PROCEDURE lee IS
BEGIN
   IF NOT c_mod190%ISOPEN THEN
     OPEN c_mod190(anypet, npetic, retescollit);
   END IF;
   tr2_nnifdec := retescollit;
   FETCH c_mod190
    INTO pspersonp,
         tr2_nnifper,
         pspersonr,
         tr2_nnifrep,
         tr2_tnomper,
         tr2_cprovin,
         tr2_csigper,
         tr2_iperint,
         tr2_iretenc,
         tr2_ireducc,
         tr2_idespeses;
   PK_ENV_COMU.traza(PK_AUTOM.trazas, pk_autom.depurar, 'Persona: '||tr2_nnifper);
   contador := contador + 1;
   IF c_mod190%NOTFOUND THEN
      v_fin := TRUE;
      CLOSE c_mod190;
   ELSE
      tr2_tnomper := REPLACE(
                           REPLACE(
                              REPLACE(
                                 REPLACE(
                                    REPLACE(
                                       REPLACE(UPPER(tr2_tnomper),'.',' '),'0','O'),
                                       '  ',' '),'ª',' '),'  ',' '),'#','Ñ');
     /* SELECT NANYNAC, NNIFCON, CSITFAM, NVL(CGRADOP,0),
             NVL(IPENSION,0)*100, NVL(IANUHIJOS,0)*100, SUBSTR(NDECMEN25,1,6), SUBSTR(NDECDISCA,1,4),
             NASCTOTAL*10+NASCENTER, SUBSTR(NASCDISCA,1,1)*10+SUBSTR(nascdisca,2,1), NVL(NDECDISEN,0)
      INTO tr2_anynacim, tr2_nnifconj, tr2_csitfami, tr2_cdiscapa,
           tr2_ipensconj, tr2_ianfills, tr2_ndesmen25, tr2_ndesdisc,
           tr2_ntotasc, tr2_nascdis, tr2_ndecdisen
      FROM fis_irpfpp
      WHERE nanyo = anypet
      AND nnumpet = npetic
      AND sperson = pspersonp;*/
      tr2_ntotdes := TO_NUMBER(SUBSTR(tr2_NDESMEN25,1,2))+TO_NUMBER(SUBSTR(tr2_NDESMEN25,3,2))+TO_NUMBER(SUBSTR(tr2_NDESMEN25,5,2))+TO_NUMBER(SUBSTR(tr2_NDESDISC,1,2))+TO_NUMBER(SUBSTR(tr2_NDESDISC,3,2));
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      PK_ENV_COMU.traza(PK_AUTOM.trazas, pk_autom.depurar, 'Error inesperado en LEE. '||SQLERRM);
--      dbms_output.put_line('Error inesperado en LEE. '||SQLERRM);
END lee;
---
---
FUNCTION fin RETURN BOOLEAN IS
BEGIN
   IF CONTADOR > 10000 THEN
      RETURN TRUE;
   ELSE
      RETURN v_fin;
   END IF;
END fin;
---
END Pk_Mod190;

/

  GRANT EXECUTE ON "AXIS"."PK_MOD190" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_MOD190" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_MOD190" TO "PROGRAMADORESCSI";
