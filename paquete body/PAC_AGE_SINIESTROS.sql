--------------------------------------------------------
--  DDL for Package Body PAC_AGE_SINIESTROS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_AGE_SINIESTROS" AS
/******************************************************************************
    NOMBRE:       PAC_AGE_SINIESTROS
    PROP?SITO:
                Tratamiento de los actores de siniestros

    REVISIONES:
    Ver        Fecha        Autor             Descripci??n
    ---------  ----------  ---------------  ------------------------------------
    1.0        14/03/2012   BFP                1. 0021524: MDP - COM - AGENTES Secci?n siniestros
******************************************************************************/

   /*************************************************************************
       Prop?sito:
                    inserir un registre a la taula sin_agentes
       param in psclave     : clave unica
       param in pcagente    : Codigo de agente
       param in pctramte    : Tipo de tramite
       param in pcramo      : c?digo ramo
       param in pctipcod    : Indica si es agente o profesional (VF 740)
       param in pctramitad  : Codigo de tramitador
       param in psprofes    : Codigo de profesional
       param in pcvalora    : Preferido/Excluido (VF 741)
       param in pfinicio    : Fecha desde
       param in pffin       : Fecha hasta
       param in pcusuari    : Usuario creador
       param in pfalta      : Fecha de alta
            return             : 0 inserci? correcta
                              <> 0 inserci? incorrecta
   *************************************************************************/
   FUNCTION f_set_actor(
      psclave IN NUMBER,
      pcagente IN NUMBER,
      pctramte IN NUMBER,
      pcramo IN NUMBER,
      pctipcod IN NUMBER,
      pctramitad IN VARCHAR2,
      psprofes IN NUMBER,
      pcvalora IN NUMBER,
      pfinicio IN DATE,
      pffin IN DATE,
      pcusuari IN VARCHAR2,
      pfalta IN DATE)
      RETURN NUMBER IS
      num_error      NUMBER;
      missatges      t_iax_mensajes;
      v_param        VARCHAR2(500)
         := 'psclave: ' || psclave || ' - pcagente: ' || pcagente || ' - pctramte: '
            || pctramte || ' - pcramo: ' || pcramo || ' - pctipcod: ' || pctipcod
            || ' - pctramitad: ' || pctramitad || ' - psprofes: ' || psprofes
            || ' - pcvalora: ' || pcvalora || ' - pfinicio: ' || pfinicio || ' - pffin: '
            || pffin || ' - pcusuari: ' || pcusuari || ' - pfalta: ' || pfalta;
      v_object       VARCHAR2(200) := 'PAC_AGE_SINIESTROS.f_set_actor';
      v_pasexec      NUMBER(8) := 1;
   BEGIN
      num_error := 1;

      IF (pcagente IS NOT NULL)
         AND(pctipcod IS NOT NULL) THEN
         BEGIN
            INSERT INTO sin_agentes
                        (sclave, cagente, ctramte,
                         cramo, ctipcod, ctramitad, sprofes,
                         cvalora, finicio, ffin,
                         cusuari, falta)
                 VALUES (NVL(psclave, (SELECT NVL(MAX(sclave), 0) + 1
                                         FROM sin_agentes)), pcagente, pctramte,
                         pcramo, pctipcod, NVL(pctramitad, NULL), NVL(psprofes, NULL),
                         NVL(pcvalora, NULL), NVL(pfinicio, f_sysdate), NVL(pffin, NULL),
                         NVL(pcusuari, NULL), NVL(pfalta, f_sysdate));

            --COMMIT;
            num_error := 0;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               v_pasexec := 2;

               UPDATE sin_agentes
                  SET cagente = pcagente,
                      ctramte = pctramte,
                      cramo = pcramo,
                      ctipcod = pctipcod,
                      ctramitad = pctramitad,
                      sprofes = psprofes,
                      cvalora = pcvalora,
                      finicio = pfinicio,
                      ffin = pffin
                WHERE sclave = psclave;

               --COMMIT;
               num_error := 0;
            WHEN OTHERS THEN
               num_error := 1;
         END;
      END IF;

      RETURN num_error;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 1;
   END f_set_actor;

/*************************************************************************
       Prop?sito:
                    donar de baixa l'actor
       param in psclave     : clave ?nica
       param in pffin    : fecha hasta
            return             : 0 actualitzaci? correcta
                              <> 0 actualitzaci? incorrecta
   *************************************************************************/
   FUNCTION f_remove_actor(psclave IN NUMBER)
      RETURN NUMBER IS
      num_error      NUMBER;
      missatges      t_iax_mensajes;
      v_param        VARCHAR2(500) := 'psclave: ' || psclave;
      v_object       VARCHAR2(200) := 'PAC_AGE_SINIESTROS.f_remove_actor';
      v_pasexec      NUMBER(8) := 1;
   BEGIN
      num_error := 1;

      IF (psclave IS NOT NULL) THEN
         BEGIN
            UPDATE sin_agentes
               SET ffin = f_sysdate
             WHERE sclave = psclave;

            num_error := 0;
         EXCEPTION
            WHEN OTHERS THEN
               num_error := 1;
         END;
      END IF;

      RETURN num_error;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 1;
   END f_remove_actor;
END pac_age_siniestros;

/

  GRANT EXECUTE ON "AXIS"."PAC_AGE_SINIESTROS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_AGE_SINIESTROS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_AGE_SINIESTROS" TO "PROGRAMADORESCSI";
