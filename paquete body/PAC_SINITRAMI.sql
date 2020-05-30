--------------------------------------------------------
--  DDL for Package Body PAC_SINITRAMI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_SINITRAMI" 
IS
/***************************************************************
   PAC_SINITRAMI: Cuerpo del paquete de las funciones para
      los triggers de actualización de las
                tablas de siniestros a partir de las de
                tramitaciones
***************************************************************/
   FUNCTION f_admet_pagaments (
      p_nsinies   IN   NUMBER,
      p_ntramit   IN   NUMBER,
      p_sperson   IN   NUMBER,
      p_ctipdes   IN   NUMBER,
      p_cpagdes   IN   NUMBER
   )
      RETURN NUMBER
   IS
      aux   NUMBER;
   BEGIN
      SELECT COUNT (*)
        INTO aux
        FROM destinatrami
       WHERE nsinies = p_nsinies
         AND ntramit <> p_ntramit
         AND sperson = p_sperson
         AND ctipdes = p_ctipdes
         AND cpagdes = 1;

      IF aux > 0
      THEN
         RETURN 1;
      ELSE
         RETURN p_cpagdes;
      END IF;
   END f_admet_pagaments;

   FUNCTION f_destinatrami_repetit (
      p_nsinies   IN   NUMBER,
      p_ntramit   IN   NUMBER,
      p_sperson   IN   NUMBER,
      p_ctipdes   IN   NUMBER
   )
      RETURN NUMBER
   IS
      aux   NUMBER;
   BEGIN
      SELECT COUNT (*)
        INTO aux
        FROM destinatrami
       WHERE nsinies = p_nsinies
         AND ntramit <> p_ntramit
         AND sperson = p_sperson
         AND ctipdes = p_ctipdes;

      RETURN aux;
   END f_destinatrami_repetit;

   FUNCTION f_primera_activitat (
      p_nsinies   IN   NUMBER,
      p_ntramit   IN   NUMBER,
      p_sperson   IN   NUMBER,
      p_ctipdes   IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      xcactpro   NUMBER;
   BEGIN
      SELECT cactpro
        INTO xcactpro
        FROM destinatrami
       WHERE nsinies = p_nsinies
         AND ntramit <> p_ntramit
         AND sperson = p_sperson
         AND ctipdes = p_ctipdes;

      RETURN xcactpro;
   END f_primera_activitat;

   FUNCTION f_primera_referencia (
      p_nsinies   IN   NUMBER,
      p_ntramit   IN   NUMBER,
      p_sperson   IN   NUMBER,
      p_ctipdes   IN   NUMBER,
      p_crefsin   IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
      xcrefper   NUMBER;
   BEGIN
      BEGIN
         SELECT crefsin
           INTO xcrefper
           FROM destinatrami
          WHERE nsinies = p_nsinies
            AND ntramit <> p_ntramit
            AND sperson = p_sperson
            AND ctipdes = p_ctipdes;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN p_crefsin;
      END;

      RETURN xcrefper;
   END f_primera_referencia;

   PROCEDURE f_calcular_valors (p_sidepag IN NUMBER)
   IS
   BEGIN
      UPDATE pagosinitrami
         SET isiniva = isinret - iimpiva,
             iimpsin = (isinret - iimpiva) - iconret,
             iretenc = iconret * pretenc / 100
       WHERE sidepag = p_sidepag;
   END f_calcular_valors;

   PROCEDURE f_calcular_valors_del_garan (p_sidepag IN NUMBER)
   IS
      viconret   NUMBER;
      visinret   NUMBER;
      viimpiva   NUMBER;
   BEGIN
      SELECT iconret, isinret, iimpiva
        INTO viconret, visinret, viimpiva
        FROM pagosinitrami
       WHERE sidepag = p_sidepag;

      IF viconret > (visinret - viimpiva)
      THEN
         UPDATE pagosinitrami
            SET iconret = isinret - iimpiva,
                isiniva = isinret - iimpiva,
                iimpsin = 0,
                iretenc = (isinret - iimpiva) * pretenc / 100
          WHERE sidepag = p_sidepag;
      ELSE
         UPDATE pagosinitrami
            SET isiniva = isinret - iimpiva,
                iimpsin = (isinret - iimpiva) - iconret,
                iretenc = iconret * pretenc / 100
          WHERE sidepag = p_sidepag;
      END IF;
   END f_calcular_valors_del_garan;

   FUNCTION f_comprobacio_pagaments (p_sidepag IN NUMBER)
      RETURN NUMBER
   IS
      err_isinret   NUMBER;
      err_iimpiva   NUMBER;
      visinret      NUMBER;
      viimpiva      NUMBER;
   BEGIN
      BEGIN
         SELECT SUM (pg.isinret), SUM (iimpiva)
           INTO visinret, viimpiva
           FROM pagogarantia pg
          WHERE pg.sidepag = p_sidepag;

         SELECT isinret - visinret, iimpiva - viimpiva
           INTO err_isinret, err_iimpiva
           FROM pagosini
          WHERE sidepag = p_sidepag;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN 0;
      END;

      IF err_isinret <> 0 OR err_iimpiva <> 0
      THEN
         RETURN 1;
      END IF;

      RETURN 0;
   END f_comprobacio_pagaments;

   FUNCTION f_ultimo_importe (
      pnsinies   IN       NUMBER,
      pcgarant   IN       NUMBER,
      piultimo   OUT      NUMBER
   )
      RETURN NUMBER
   IS
   BEGIN
      SELECT v1.ivalora
        INTO piultimo
        FROM valorasini v1
       WHERE v1.nsinies = pnsinies
         AND v1.cgarant = pcgarant
         AND v1.fvalora =
                  (SELECT MAX (v2.fvalora)
                     FROM valorasini v2
                    WHERE v2.nsinies = v1.nsinies AND v2.cgarant = v1.cgarant);

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         piultimo := 0;
         RETURN 0;
   END f_ultimo_importe;

   FUNCTION f_tnou_iant (
      pnsinies   IN       NUMBER,
      pntramit   IN       NUMBER,
      pcgarant   IN       NUMBER,
      iant       OUT      NUMBER,
      tnou       OUT      NUMBER
   )
      RETURN NUMBER
   IS
      tant   NUMBER;
   BEGIN
      SELECT MAX (nvalora)
        INTO tnou
        FROM valorasinitrami
       WHERE nsinies = pnsinies AND ntramit = pntramit AND cgarant = pcgarant;

      tant := tnou - 1;

      IF tant <> 0
      THEN
         SELECT ivalora
           INTO iant
           FROM valorasinitrami
          WHERE nsinies = pnsinies
            AND ntramit = pntramit
            AND cgarant = pcgarant
            AND nvalora = tant;
      ELSE
         iant := 0;
      END IF;

      RETURN 0;
   END f_tnou_iant;

   FUNCTION f_inou (
      pnsinies   IN       NUMBER,
      pntramit   IN       NUMBER,
      pcgarant   IN       NUMBER,
      tnou       IN       NUMBER,
      inou       OUT      NUMBER
   )
      RETURN NUMBER
   IS
   BEGIN
      SELECT ivalora
        INTO inou
        FROM valorasinitrami
       WHERE nsinies = pnsinies
         AND ntramit = pntramit
         AND cgarant = pcgarant
         AND nvalora = tnou;

      RETURN 0;
   END f_inou;

   FUNCTION f_ins_valorasini (
      pnsinies   IN   NUMBER,
      pntramit   IN   NUMBER,
      pcgarant   IN   NUMBER,
      pfvalora   IN   DATE,
      pivalora   IN   NUMBER
   )
      RETURN NUMBER
   IS
      iant      NUMBER;
      inou      NUMBER;
      tnou      NUMBER;
      aux       NUMBER;
      iultimo   NUMBER;
   BEGIN
      -- Comprobació fvalora
      SELECT COUNT (*)
        INTO aux
        FROM valorasini
       WHERE nsinies = pnsinies AND cgarant = pcgarant AND fvalora = pfvalora;

      IF aux > 0
      THEN
         -- La clau estarà repetida a VALORASINI
         RETURN 20001;
      END IF;

      -- Valors per posar
      aux := pac_sinitrami.f_ultimo_importe (pnsinies, pcgarant, iultimo);
      aux :=
          pac_sinitrami.f_tnou_iant (pnsinies, pntramit, pcgarant, iant, tnou);
      aux := pac_sinitrami.f_inou (pnsinies, pntramit, pcgarant, tnou, inou);

      -- INSERT per posar
      INSERT INTO valorasini
                  (nsinies, cgarant, fvalora, ivalora
                  )
           VALUES (pnsinies, pcgarant, pfvalora, (iultimo - iant + inou)
                  );

      RETURN 0;
   END f_ins_valorasini;

   FUNCTION f_ins_destinatarios (
      pnsinies   IN   NUMBER,
      pntramit   IN   NUMBER,
      psperson   IN   NUMBER,
      pctipdes   IN   NUMBER,
      pcpagdes   IN   NUMBER,
      pcactpro   IN   NUMBER,
      pcrefsin   IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      repetit_n   NUMBER;
      vcpagdes    NUMBER;
      vcactpro    NUMBER;
      vcrefper    NUMBER;
   BEGIN
      repetit_n :=
         pac_sinitrami.f_destinatrami_repetit (pnsinies,
                                               pntramit,
                                               psperson,
                                               pctipdes
                                              );

      IF repetit_n = 0
      THEN
         -- el nou no existeix
         INSERT INTO destinatarios
                     (nsinies, sperson, ctipdes, cpagdes, cactpro,
                      crefper
                     )
              VALUES (pnsinies, psperson, pctipdes, pcpagdes, pcactpro,
                      pcrefsin
                     );
      ELSE
         vcpagdes :=
            pac_sinitrami.f_admet_pagaments (pnsinies,
                                             pntramit,
                                             psperson,
                                             pctipdes,
                                             pcpagdes
                                            );
         vcactpro :=
            pac_sinitrami.f_primera_activitat (pnsinies,
                                               pntramit,
                                               psperson,
                                               pctipdes
                                              );
         vcrefper :=
            pac_sinitrami.f_primera_referencia (pnsinies,
                                                pntramit,
                                                psperson,
                                                pctipdes,
                                                pcrefsin
                                               );

         UPDATE destinatarios
            SET cpagdes = vcpagdes,
                cactpro = vcactpro,
                crefper = vcrefper
          WHERE nsinies = pnsinies AND sperson = psperson
                AND ctipdes = pctipdes;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN SQLCODE;
   END f_ins_destinatarios;

   FUNCTION f_act_destinatarios (
      pnsinies   IN   NUMBER,
      pntramit   IN   NUMBER,
      psperson   IN   NUMBER,
      pctipdes   IN   NUMBER,
      pcpagdes   IN   NUMBER,
      pcactpro   IN   NUMBER,
      pcrefsin   IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      vcpagdes   NUMBER;
   BEGIN
      vcpagdes :=
         pac_sinitrami.f_admet_pagaments (pnsinies,
                                          pntramit,
                                          psperson,
                                          pctipdes,
                                          pcpagdes
                                         );

      UPDATE destinatarios
         SET cpagdes = vcpagdes
       WHERE nsinies = pnsinies AND sperson = psperson AND ctipdes = pctipdes;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN SQLCODE;
   END f_act_destinatarios;

   FUNCTION f_del_destinatarios (
      pnsinies   IN   NUMBER,
      pntramit   IN   NUMBER,
      psperson   IN   NUMBER,
      pctipdes   IN   NUMBER,
      pcpagdes   IN   NUMBER,
      pcactpro   IN   NUMBER,
      pcrefsin   IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      vcpagdes    NUMBER;
      vcactpro    NUMBER;
      vcrefper    NUMBER;
      repetit_v   NUMBER;
   BEGIN
      repetit_v :=
         pac_sinitrami.f_destinatrami_repetit (pnsinies,
                                               pntramit,
                                               psperson,
                                               pctipdes
                                              );

      IF repetit_v = 0
      THEN
         -- Aquest destinatari no està present a cap altra tramitació
         DELETE FROM destinatarios
               WHERE nsinies = pnsinies
                 AND sperson = psperson
                 AND ctipdes = pctipdes;
      ELSE
         -- Aquest destinatari està present en alguna altra tramitació
         vcpagdes :=
            pac_sinitrami.f_admet_pagaments (pnsinies,
                                             pntramit,
                                             psperson,
                                             pctipdes,
                                             pcpagdes
                                            );
         vcactpro :=
            pac_sinitrami.f_primera_activitat (pnsinies,
                                               pntramit,
                                               psperson,
                                               pctipdes
                                              );
         vcrefper :=
            pac_sinitrami.f_primera_referencia (pnsinies,
                                                pntramit,
                                                psperson,
                                                pctipdes,
                                                pcrefsin
                                               );

         UPDATE destinatarios
            SET cpagdes = vcpagdes,
                cactpro = vcactpro,
                crefper = vcrefper
          WHERE nsinies = pnsinies AND sperson = psperson
                AND ctipdes = pctipdes;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN SQLCODE;
   END;
END pac_sinitrami;

/

  GRANT EXECUTE ON "AXIS"."PAC_SINITRAMI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SINITRAMI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SINITRAMI" TO "PROGRAMADORESCSI";
