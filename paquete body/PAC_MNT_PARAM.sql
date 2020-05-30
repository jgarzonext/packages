--------------------------------------------------------
--  DDL for Package Body PAC_MNT_PARAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MNT_PARAM" IS
   /*************************************************************************
      FUNCTION F_GET_DESCPARAM
      Devuelve la descripción del parámetro de entrada.
         param in pcparam   : código de parámetro
         param in pcidioma  : código del idioma
         param out pcdesc   : descripción del parámetro
         return             : 0 si ha ido bien
                              1 si ha ido mal
   *************************************************************************/
   FUNCTION f_get_descparam(pcparam IN VARCHAR2, pcidioma IN NUMBER, pcdesc OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      --BUG 5176 - 06/03/2009 - JRB - Se modifica
      SELECT tparam
        INTO pcdesc
        FROM desparam
       WHERE cparam = pcparam
         AND cidioma = pcidioma;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_mnt_param.f_get_descparam', 1,
                     'when others pcparam, pcidioma =' || pcparam || ',' || pcidioma, SQLERRM);
         RETURN 111866;
   END f_get_descparam;

------------------------------------------------------------------------------------------
   /*************************************************************************
      FUNCTION F_INS_PARPRODUCTOS
      Realiza el insert en la tabla parproductos.
         param in psproduc : código de producto
         param in pcparam  : código de parámetro
         param in pcvalpar : valor numérico del parámetro
         param in ptvalpar : valor Texto del parámetro
         param in pfvalpar : valor Fecha del parámetro
         return            : 0 si todo es correcto
                             código de error en caso de que lo haya
   *************************************************************************/
   FUNCTION f_ins_parproductos(
      psproduc IN NUMBER,
      pcparam IN VARCHAR2,
      pcvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE)
      RETURN NUMBER IS
      vctipo         codparam.ctipo%TYPE;
   BEGIN
      SELECT ctipo
        INTO vctipo
        FROM codparam
       WHERE cparam = pcparam;

      IF vctipo = 1
         AND ptvalpar IS NOT NULL
         AND pcvalpar IS NULL
         AND pfvalpar IS NULL THEN
         INSERT INTO parproductos
                     (sproduc, cparpro, tvalpar)
              VALUES (psproduc, pcparam, ptvalpar);
      ELSIF vctipo IN(2, 4)
            AND ptvalpar IS NULL
            AND pcvalpar IS NOT NULL
            AND pfvalpar IS NULL THEN
         INSERT INTO parproductos
                     (sproduc, cparpro, cvalpar)
              VALUES (psproduc, pcparam, pcvalpar);
      ELSIF vctipo = 3
            AND ptvalpar IS NULL
            AND pcvalpar IS NULL
            AND pfvalpar IS NOT NULL THEN
         INSERT INTO parproductos
                     (sproduc, cparpro, fvalpar)
              VALUES (psproduc, pcparam, pfvalpar);
      ELSE
         RETURN 109998;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         BEGIN
            IF vctipo = 1
               AND ptvalpar IS NOT NULL
               AND pcvalpar IS NULL
               AND pfvalpar IS NULL THEN
               UPDATE parproductos
                  SET tvalpar = ptvalpar
                WHERE sproduc = psproduc
                  AND cparpro = pcparam;
            ELSIF vctipo IN(2, 4)
                  AND ptvalpar IS NULL
                  AND pcvalpar IS NOT NULL
                  AND pfvalpar IS NULL THEN
               UPDATE parproductos
                  SET cvalpar = pcvalpar
                WHERE sproduc = psproduc
                  AND cparpro = pcparam;
            ELSIF vctipo = 3
                  AND ptvalpar IS NULL
                  AND pcvalpar IS NULL
                  AND pfvalpar IS NOT NULL THEN
               UPDATE parproductos
                  SET fvalpar = pfvalpar
                WHERE sproduc = psproduc
                  AND cparpro = pcparam;
            ELSE
               RETURN 109998;
            END IF;

            RETURN 0;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_mnt_param.f_ins_parproductos', 1,
                           'when others pcparam =' || pcparam, SQLERRM);
               RETURN 109998;
         END;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_mnt_param.f_ins_parproductos', 1,
                     'when others pcparam =' || pcparam, SQLERRM);
         RETURN 109998;
   END f_ins_parproductos;

   /*************************************************************************
      FUNCTION F_DEL_PARPRODUCTOS
      Borra un parámetro de la tabla parproductos.
         param in psproduc : código de producto
         param in pcparam  : código de parámetro
         return            : 0 si todo es correcto
                             código de error en caso de que lo haya
   *************************************************************************/
   FUNCTION f_del_parproductos(psproduc IN NUMBER, pcparam IN VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      IF psproduc IS NOT NULL
         AND pcparam IS NOT NULL THEN
         DELETE FROM parproductos
               WHERE sproduc = psproduc
                 AND cparpro = pcparam;

         RETURN 0;
      ELSE
         RETURN 109998;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_mnt_param.f_del_parproductos', 1,
                     'when others pcparam =' || pcparam, SQLERRM);
         RETURN 109998;
   END f_del_parproductos;

   /*************************************************************************
      FUNCTION F_INS_PARACTIVIDAD
      Realiza el insert en la tabla paractividad.
         param in psproduc : código de producto
         param in pcactivi : código de actividad
         param in pcparam  : código de parámetro
         param in pcvalpar : valor numérico del parámetro
         param in ptvalpar : valor Texto del parámetro
         param in pfvalpar : valor Fecha del parámetro
         return            : 0 si todo es correcto
                             código de error en caso de que lo haya
   *************************************************************************/
   FUNCTION f_ins_paractividad(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcparam IN VARCHAR2,
      pcvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE)
      RETURN NUMBER IS
      vctipo         codparam.ctipo%TYPE;
   BEGIN
      SELECT ctipo
        INTO vctipo
        FROM codparam
       WHERE cparam = pcparam;

      IF vctipo = 1
         AND ptvalpar IS NOT NULL
         AND pcvalpar IS NULL
         AND pfvalpar IS NULL
         AND pcactivi IS NOT NULL THEN
         INSERT INTO paractividad
                     (sproduc, cparame, tvalpar, cactivi, ctippar)
              VALUES (psproduc, pcparam, ptvalpar, pcactivi, vctipo);
      ELSIF vctipo IN(2, 4)
            AND ptvalpar IS NULL
            AND pcvalpar IS NOT NULL
            AND pfvalpar IS NULL
            AND pcactivi IS NOT NULL THEN
         INSERT INTO paractividad
                     (sproduc, cparame, nvalpar, cactivi, ctippar)
              VALUES (psproduc, pcparam, pcvalpar, pcactivi, vctipo);
      ELSIF vctipo = 3
            AND ptvalpar IS NULL
            AND pcvalpar IS NULL
            AND pfvalpar IS NOT NULL
            AND pcactivi IS NOT NULL THEN
         INSERT INTO paractividad
                     (sproduc, cparame, fvalpar, cactivi)
              VALUES (psproduc, pcparam, pfvalpar, pcactivi);
      ELSE
         RETURN 800577;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         BEGIN
            IF vctipo = 1
               AND ptvalpar IS NOT NULL
               AND pcvalpar IS NULL
               AND pfvalpar IS NULL
               AND pcactivi IS NOT NULL THEN
               UPDATE paractividad
                  SET tvalpar = ptvalpar
                WHERE sproduc = psproduc
                  AND cparame = pcparam
                  AND cactivi = pcactivi;
            ELSIF vctipo IN(2, 4)
                  AND ptvalpar IS NULL
                  AND pcvalpar IS NOT NULL
                  AND pfvalpar IS NULL
                  AND pcactivi IS NOT NULL THEN
               UPDATE paractividad
                  SET nvalpar = pcvalpar
                WHERE sproduc = psproduc
                  AND cparame = pcparam
                  AND cactivi = pcactivi;
            ELSIF vctipo = 3
                  AND ptvalpar IS NULL
                  AND pcvalpar IS NULL
                  AND pfvalpar IS NOT NULL
                  AND pcactivi IS NOT NULL THEN
               UPDATE paractividad
                  SET fvalpar = pfvalpar
                WHERE sproduc = psproduc
                  AND cparame = pcparam
                  AND cactivi = pcactivi;
            ELSE
               RETURN 800577;
            END IF;

            RETURN 0;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_mnt_param.f_ins_paractividad', 1,
                           'when others pcparam =' || pcparam, SQLERRM);
               RETURN 800577;
         END;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_mnt_param.f_ins_paractividad', 1,
                     'when others pcparam =' || pcparam, SQLERRM);
         RETURN 800577;
   END f_ins_paractividad;

   /*************************************************************************
      FUNCTION F_DEL_PARACTIVIDAD
      Borra un parámetro de la tabla paractividad.
         param in psproduc : código de producto
         param in pcactivi : código de actividad
         param in pcparam  : código de parámetro
         return            : 0 si todo es correcto
                             código de error en caso de que lo haya
   *************************************************************************/
   FUNCTION f_del_paractividad(psproduc IN NUMBER, pcactivi IN NUMBER, pcparam IN VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      IF psproduc IS NOT NULL
         AND pcactivi IS NOT NULL
         AND pcparam IS NOT NULL THEN
         DELETE FROM paractividad
               WHERE sproduc = psproduc
                 AND cparame = pcparam
                 AND cactivi = pcactivi;

         RETURN 0;
      ELSE
         RETURN 800577;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_mnt_param.f_del_paractividad', 1,
                     'when others pcparam =' || pcparam, SQLERRM);
         RETURN 800577;
   END f_del_paractividad;

   /*************************************************************************
      FUNCTION F_INS_PARGARANPRO
      Realiza el insert en la tabla pargaranpro.
         param in psproduc : código de producto
         param in pcactivi : código de actividad
         param in pcgarant : código de garantía
         param in pcparam  : código de parámetro
         param in pcvalpar : valor numérico del parámetro
         param in ptvalpar : valor Texto del parámetro
         param in pfvalpar : valor Fecha del parámetro
         param in pcramo   : código de ramo
         param in pcmodali : código de modalidad
         param in pctipseg : código de tipo de seguro
         param in pccolect : código de colectividad
         return            : 0 si todo es correcto
                             código de error en caso de que lo haya
   *************************************************************************/
   FUNCTION f_ins_pargaranpro(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcparam IN VARCHAR2,
      pcvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE,
      pcramo IN NUMBER DEFAULT NULL,
      pcmodali IN NUMBER DEFAULT NULL,
      pctipseg IN NUMBER DEFAULT NULL,
      pccolect IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vctipo         codparam.ctipo%TYPE;
      vcramo         productos.cramo%TYPE;
      vcmodali       productos.cmodali%TYPE;
      vctipseg       productos.ctipseg%TYPE;
      vccolect       productos.ccolect%TYPE;
   BEGIN
      SELECT ctipo
        INTO vctipo
        FROM codparam
       WHERE cparam = pcparam;

      IF pcramo IS NULL
         OR pcmodali IS NULL
         OR pctipseg IS NULL
         OR pccolect IS NULL THEN
         SELECT cramo, cmodali, ctipseg, ccolect
           INTO vcramo, vcmodali, vctipseg, vccolect
           FROM productos
          WHERE sproduc = psproduc;
      ELSE
         vcramo := pcramo;
         vcmodali := pcmodali;
         vctipseg := pctipseg;
         vccolect := pccolect;
      END IF;

      IF vctipo = 1
         AND ptvalpar IS NOT NULL
         AND pcvalpar IS NULL
         AND pfvalpar IS NULL
         AND pcactivi IS NOT NULL THEN
         INSERT INTO pargaranpro
                     (cpargar, tvalpar, cactivi, cgarant, cramo, cmodali, ctipseg,
                      ccolect, sproduc)
              VALUES (pcparam, ptvalpar, pcactivi, pcgarant, vcramo, vcmodali, vctipseg,
                      vccolect, psproduc);
      ELSIF vctipo IN(2, 4)
            AND ptvalpar IS NULL
            AND pcvalpar IS NOT NULL
            AND pfvalpar IS NULL
            AND pcactivi IS NOT NULL THEN
         INSERT INTO pargaranpro
                     (cpargar, cvalpar, cactivi, cgarant, cramo, cmodali, ctipseg,
                      ccolect, sproduc)
              VALUES (pcparam, pcvalpar, pcactivi, pcgarant, vcramo, vcmodali, vctipseg,
                      vccolect, psproduc);
      ELSIF vctipo = 3
            AND ptvalpar IS NULL
            AND pcvalpar IS NULL
            AND pfvalpar IS NOT NULL
            AND pcactivi IS NOT NULL THEN
         INSERT INTO pargaranpro
                     (cpargar, fvalpar, cactivi, cgarant, cramo, cmodali, ctipseg,
                      ccolect, sproduc)
              VALUES (pcparam, pfvalpar, pcactivi, pcgarant, vcramo, vcmodali, vctipseg,
                      vccolect, psproduc);
      ELSE
         RETURN 108718;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         BEGIN
            IF vctipo = 1
               AND ptvalpar IS NOT NULL
               AND pcvalpar IS NULL
               AND pfvalpar IS NULL
               AND pcactivi IS NOT NULL THEN
               UPDATE pargaranpro
                  SET tvalpar = ptvalpar
                WHERE cpargar = pcparam
                  AND cactivi = pcactivi
                  AND cgarant = pcgarant
                  AND cramo = vcramo
                  AND cmodali = vcmodali
                  AND ctipseg = vctipseg
                  AND ccolect = vccolect
                  AND sproduc = psproduc;
            ELSIF vctipo IN(2, 4)
                  AND ptvalpar IS NULL
                  AND pcvalpar IS NOT NULL
                  AND pfvalpar IS NULL
                  AND pcactivi IS NOT NULL THEN
               UPDATE pargaranpro
                  SET cvalpar = pcvalpar
                WHERE cpargar = pcparam
                  AND cactivi = pcactivi
                  AND cgarant = pcgarant
                  AND cramo = vcramo
                  AND cmodali = vcmodali
                  AND ctipseg = vctipseg
                  AND ccolect = vccolect
                  AND sproduc = psproduc;
            ELSIF vctipo = 3
                  AND ptvalpar IS NULL
                  AND pcvalpar IS NULL
                  AND pfvalpar IS NOT NULL
                  AND pcactivi IS NOT NULL THEN
               UPDATE pargaranpro
                  SET fvalpar = pfvalpar
                WHERE cpargar = pcparam
                  AND cactivi = pcactivi
                  AND cgarant = pcgarant
                  AND cramo = vcramo
                  AND cmodali = vcmodali
                  AND ctipseg = vctipseg
                  AND ccolect = vccolect
                  AND sproduc = psproduc;
            ELSE
               RETURN 108718;
            END IF;

            RETURN 0;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_mnt_param.f_ins_pargaranpro', 1,
                           'when others pcparam =' || pcparam, SQLERRM);
               RETURN 108718;
         END;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_mnt_param.f_ins_pargaranpro', 1,
                     'when others pcparam =' || pcparam, SQLERRM);
         RETURN 108718;
   END f_ins_pargaranpro;

   /*************************************************************************
      FUNCTION F_DEL_PARGARANPRO
      Borra un parámetro de la tabla pargaranpro.
         param in psproduc : código de producto
         param in pcactivi : código de actividad
         param in pcgarant : código de garantía
         param in pcparam  : código de parámetro
         return            : 0 si todo es correcto
                             código de error en caso de que lo haya
   *************************************************************************/
   FUNCTION f_del_pargaranpro(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcparam IN VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      IF psproduc IS NOT NULL
         AND pcactivi IS NOT NULL
         AND pcgarant IS NOT NULL
         AND pcparam IS NOT NULL THEN
         DELETE FROM pargaranpro
               WHERE sproduc = psproduc
                 AND cpargar = pcparam
                 AND cactivi = pcactivi
                 AND cgarant = pcgarant;

         RETURN 0;
      ELSE
         RETURN 108718;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_mnt_param.f_del_pargaranpro', 1,
                     'when others pcparam =' || pcparam, SQLERRM);
         RETURN 108718;
   END f_del_pargaranpro;

   /*************************************************************************
      FUNCTION F_INS_PARINSTALACION
      Realiza el insert en la tabla parinstalacion.
         param in pcparam  : código de parámetro
         param in pcvalpar : valor numérico del parámetro
         param in ptvalpar : valor Texto del parámetro
         param in pfvalpar : valor Fecha del parámetro
         return            : 0 si todo es correcto
                             código de error en caso de que lo haya
   *************************************************************************/
   FUNCTION f_ins_parinstalacion(
      pcparam IN VARCHAR2,
      pcvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE)
      RETURN NUMBER IS
      vctipo         codparam.ctipo%TYPE;
   BEGIN
      SELECT ctipo
        INTO vctipo
        FROM codparam
       WHERE cparam = pcparam;

      IF vctipo = 1
         AND ptvalpar IS NOT NULL
         AND pcvalpar IS NULL
         AND pfvalpar IS NULL THEN
         INSERT INTO parinstalacion
                     (cparame, tvalpar, ctippar)
              VALUES (pcparam, ptvalpar, vctipo);
      ELSIF vctipo IN(2, 4)
            AND ptvalpar IS NULL
            AND pcvalpar IS NOT NULL
            AND pfvalpar IS NULL THEN
         INSERT INTO parinstalacion
                     (ctippar, cparame, nvalpar)
              VALUES (vctipo, pcparam, pcvalpar);
      ELSIF vctipo = 3
            AND ptvalpar IS NULL
            AND pcvalpar IS NULL
            AND pfvalpar IS NOT NULL THEN
         INSERT INTO paractividad
                     (ctippar, cparame, fvalpar)
              VALUES (vctipo, pcparam, pfvalpar);
      ELSE
         RETURN 111561;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         BEGIN
            IF vctipo = 1
               AND ptvalpar IS NOT NULL
               AND pcvalpar IS NULL
               AND pfvalpar IS NULL THEN
               UPDATE parinstalacion
                  SET tvalpar = ptvalpar
                WHERE cparame = pcparam
                  AND ctippar = vctipo;
            ELSIF vctipo IN(2, 4)
                  AND ptvalpar IS NULL
                  AND pcvalpar IS NOT NULL
                  AND pfvalpar IS NULL THEN
               UPDATE parinstalacion
                  SET nvalpar = pcvalpar
                WHERE cparame = pcparam
                  AND ctippar = vctipo;
            ELSIF vctipo = 3
                  AND ptvalpar IS NULL
                  AND pcvalpar IS NULL
                  AND pfvalpar IS NOT NULL THEN
               UPDATE parinstalacion
                  SET fvalpar = pfvalpar
                WHERE cparame = pcparam
                  AND ctippar = vctipo;
            ELSE
               RETURN 111561;
            END IF;

            RETURN 0;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_mnt_param.f_ins_parinstalacion', 1,
                           'when others pcparam =' || pcparam, SQLERRM);
               RETURN 111561;
         END;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_mnt_param.f_ins_parinstalacion', 1,
                     'when others pcparam =' || pcparam, SQLERRM);
         RETURN 111561;
   END f_ins_parinstalacion;

   /*************************************************************************
      FUNCTION F_INS_PARINSTALACION
      Borra un parámetro de la tabla parinstalacion.
         param in pcparam  : código de parámetro
         return            : 0 si todo es correcto
                             código de error en caso de que lo haya
   *************************************************************************/
   FUNCTION f_del_parinstalacion(pcparam IN VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      IF pcparam IS NOT NULL THEN
         DELETE FROM parinstalacion
               WHERE cparame = pcparam;

         RETURN 0;
      ELSE
         RETURN 111561;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_mnt_param.f_del_parinstalacion', 1,
                     'when others pcparam =' || pcparam, SQLERRM);
         RETURN 111561;
   END f_del_parinstalacion;

   /*************************************************************************
      FUNCTION F_INS_PAREMPRESAS
      Realiza el insert en la tabla parempresas.
         param in pcempres : código de empresa
         param in pcparam  : código de parámetro
         param in pcvalpar : valor numérico del parámetro
         param in ptvalpar : valor Texto del parámetro
         param in pfvalpar : valor Fecha del parámetro
         return            : 0 si todo es correcto
                             código de error en caso de que lo haya
   *************************************************************************/
   FUNCTION f_ins_parempresas(
      pcempres IN NUMBER,
      pcparam IN VARCHAR2,
      pcvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE)
      RETURN NUMBER IS
      vctipo         codparam.ctipo%TYPE;
   BEGIN
      SELECT ctipo
        INTO vctipo
        FROM codparam
       WHERE cparam = pcparam;

      IF vctipo = 1
         AND ptvalpar IS NOT NULL
         AND pcvalpar IS NULL
         AND pfvalpar IS NULL
         AND pcempres IS NOT NULL THEN
         INSERT INTO parempresas
                     (cparam, tvalpar, cempres)
              VALUES (pcparam, ptvalpar, pcempres);
      ELSIF vctipo IN(2, 4)
            AND ptvalpar IS NULL
            AND pcvalpar IS NOT NULL
            AND pfvalpar IS NULL
            AND pcempres IS NOT NULL THEN
         INSERT INTO parempresas
                     (cparam, nvalpar, cempres)
              VALUES (pcparam, pcvalpar, pcempres);
      ELSIF vctipo = 3
            AND ptvalpar IS NULL
            AND pcvalpar IS NULL
            AND pfvalpar IS NOT NULL
            AND pcempres IS NOT NULL THEN
         INSERT INTO parempresas
                     (cparam, fvalpar, cempres)
              VALUES (pcparam, pfvalpar, pcempres);
      ELSE
         RETURN 108545;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         BEGIN
            IF vctipo = 1
               AND ptvalpar IS NOT NULL
               AND pcvalpar IS NULL
               AND pfvalpar IS NULL
               AND pcempres IS NOT NULL THEN
               UPDATE parempresas
                  SET tvalpar = ptvalpar
                WHERE cparam = pcparam
                  AND cempres = pcempres;
            ELSIF vctipo IN(2, 4)
                  AND ptvalpar IS NULL
                  AND pcvalpar IS NOT NULL
                  AND pfvalpar IS NULL
                  AND pcempres IS NOT NULL THEN
               UPDATE parempresas
                  SET nvalpar = pcvalpar
                WHERE cparam = pcparam
                  AND cempres = pcempres;
            ELSIF vctipo = 3
                  AND ptvalpar IS NULL
                  AND pcvalpar IS NULL
                  AND pfvalpar IS NOT NULL
                  AND pcempres IS NOT NULL THEN
               UPDATE parempresas
                  SET fvalpar = pfvalpar
                WHERE cparam = pcparam
                  AND cempres = pcempres;
            ELSE
               RETURN 108545;
            END IF;

            RETURN 0;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_mnt_param.f_ins_parempresas', 1,
                           'when others pcparam =' || pcparam, SQLERRM);
               RETURN 108545;
         END;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_mnt_param.f_ins_parempresas', 1,
                     'when others pcparam =' || pcparam, SQLERRM);
         RETURN 108545;
   END f_ins_parempresas;

   /*************************************************************************
      FUNCTION F_DEL_PAREMPRESAS
      Borra un parámetro de la tabla parempresas.
         param in pcempres : código de empresa
         param in pcparam  : código de parámetro
         return            : 0 si todo es correcto
                             código de error en caso de que lo haya
   *************************************************************************/
   FUNCTION f_del_parempresas(pcempres IN NUMBER, pcparam IN VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      IF pcempres IS NOT NULL
         AND pcparam IS NOT NULL THEN
         DELETE FROM parempresas
               WHERE cparam = pcparam
                 AND cempres = pcempres;

         RETURN 0;
      ELSE
         RETURN 108545;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_mnt_param.f_del_parempresas', 1,
                     'when others pcparam =' || pcparam, SQLERRM);
         RETURN 108545;
   END f_del_parempresas;

   /*************************************************************************
      FUNCTION F_INS_PARCONEXION
      Realiza el insert en la tabla parconexion.
         param in pcparam  : código de parámetro
         param in pcvalpar : valor numérico del parámetro
         param in ptvalpar : valor Texto del parámetro
         param in pfvalpar : valor Fecha del parámetro
         return            : 0 si todo es correcto
                             código de error en caso de que lo haya
   *************************************************************************/
   FUNCTION f_ins_parconexion(
      pcparam IN VARCHAR2,
      pcvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE)
      RETURN NUMBER IS
      vctipo         codparam.ctipo%TYPE;
   BEGIN
      SELECT ctipo
        INTO vctipo
        FROM codparam
       WHERE cparam = pcparam;

      IF vctipo = 1
         AND ptvalpar IS NOT NULL
         AND pcvalpar IS NULL
         AND pfvalpar IS NULL THEN
         INSERT INTO parconexion
                     (cparame, tvalpar)
              VALUES (pcparam, ptvalpar);
      ELSIF vctipo IN(2, 4)
            AND ptvalpar IS NULL
            AND pcvalpar IS NOT NULL
            AND pfvalpar IS NULL THEN
         INSERT INTO parconexion
                     (cparame, cvalpar)
              VALUES (pcparam, pcvalpar);
      ELSIF vctipo = 3
            AND ptvalpar IS NULL
            AND pcvalpar IS NULL
            AND pfvalpar IS NOT NULL THEN
         INSERT INTO parconexion
                     (cparame, fvalpar)
              VALUES (pcparam, pfvalpar);
      ELSE
         RETURN 108545;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         BEGIN
            IF vctipo = 1
               AND ptvalpar IS NOT NULL
               AND pcvalpar IS NULL
               AND pfvalpar IS NULL THEN
               UPDATE parconexion
                  SET tvalpar = ptvalpar
                WHERE cparame = pcparam;
            ELSIF vctipo IN(2, 4)
                  AND ptvalpar IS NULL
                  AND pcvalpar IS NOT NULL
                  AND pfvalpar IS NULL THEN
               UPDATE parconexion
                  SET cvalpar = pcvalpar
                WHERE cparame = pcparam;
            ELSIF vctipo = 3
                  AND ptvalpar IS NULL
                  AND pcvalpar IS NULL
                  AND pfvalpar IS NOT NULL THEN
               UPDATE parconexion
                  SET fvalpar = pfvalpar
                WHERE cparame = pcparam;
            ELSE
               RETURN 102530;
            END IF;

            RETURN 0;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_mnt_param.f_ins_parconexion', 1,
                           'when others pcparam =' || pcparam, SQLERRM);
               RETURN 108545;
         END;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_mnt_param.f_ins_parconexion', 1,
                     'when others pcparam =' || pcparam, SQLERRM);
         RETURN 108545;
   END f_ins_parconexion;

   /*************************************************************************
      FUNCTION F_DEL_PARCONEXION
      Borra un parámetro de la tabla parconexion.
         param in pcparam  : código de parámetro
         return            : 0 si todo es correcto
                             código de error en caso de que lo haya
   *************************************************************************/
   FUNCTION f_del_parconexion(pcparam IN VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      IF pcparam IS NOT NULL THEN
         DELETE FROM parconexion
               WHERE cparame = pcparam;

         RETURN 0;
      ELSE
         RETURN 108545;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_mnt_param.f_del_parconexion', 1,
                     'when others pcparam =' || pcparam, SQLERRM);
         RETURN 108545;
   END f_del_parconexion;

   --Bug 8789 - 18/02/2009 - AMC - Se crean las funciones para Parámetros Movimiento

   /*************************************************************************
      FUNCTION F_GET_MOVPARAM
      Obtiene el valor del parametro de parmotmov.
         param in psproduc : código del producto
         param in pcmotmov : código del motivo del movimiento
         param out psquery : select que devuelve el valor
         return            : 0 si todo es correcto
                             código de error en caso de que lo haya
   *************************************************************************/
   FUNCTION f_get_movparam(psproduc IN NUMBER, pcmotmov IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      IF psproduc IS NOT NULL
         OR pcmotmov IS NOT NULL THEN
         psquery := '' || '   SELECT c.cparam,tparam,ctipo,cutili,cvalpar,tvalpar,fvalpar '
                    || '     FROM codparam C, desparam D, parmotmov PMM '
                    || '    WHERE C.cparam = D.cparam ' || '      AND C.cutili = 6 '
                    || '      AND D.cidioma = ' || pac_md_common.f_get_cxtidioma
                    || '      AND PMM.sproduc (+) = ' || psproduc
                    || '      AND PMM.cmotmov (+) = ' || pcmotmov || ' ORDER BY C.norden';
         RETURN 0;
      ELSE
         RETURN 108545;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_mnt_param.F_Get_MovParam', 1,
                     'when others psproduc =' || psproduc || ' pcmotmov =' || pcmotmov,
                     SQLERRM);
         RETURN 108545;
   END f_get_movparam;

   /*************************************************************************
      FUNCTION F_DEL_PARMOTMOV
      Borra de parmotmov
         param in psproduc : código del producto
         param in pcmotmov : código del motivo del movimiento
         param in pcparam  : código del parametro
         return            : 0 si todo es correcto
                             código de error en caso de que lo haya
   *************************************************************************/
   FUNCTION f_del_parmotmov(psproduc IN NUMBER, pcmotmov IN NUMBER, pcparam IN VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      IF psproduc IS NOT NULL
         AND pcmotmov IS NOT NULL
         AND pcparam IS NOT NULL THEN
         DELETE FROM parmotmov
               WHERE sproduc = psproduc
                 AND cparmot = pcparam
                 AND cmotmov = pcmotmov;

         RETURN 0;
      ELSE
         RETURN 108545;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_mnt_param.f_del_parmotmov', 1,
                     'when others pcparam =' || pcparam || ' psproduc = ' || psproduc
                     || ' pcmotmov = ' || pcmotmov,
                     SQLERRM);
         RETURN 108545;
   END f_del_parmotmov;

   /*************************************************************************
      FUNCTION F_INS_PARMOTMOV
      Inserta en parmotmov.
         param in psproduc : código del producto
         param in pcmotmov : código del motivo del movimiento
         param in pcparam  : código del parametro
         param in pcvalpar : valor del parametro
         param in ptvalpar : valor de texto del parametro
         param in pfvalpar : valor de fecha del parametro
         return            : 0 si todo es correcto
                             código de error en caso de que lo haya
   *************************************************************************/
   FUNCTION f_ins_parmotmov(
      psproduc IN NUMBER,
      pcmotmov IN NUMBER,
      pcparam IN VARCHAR2,
      pcvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE)
      RETURN NUMBER IS
      vctipo         codparam.ctipo%TYPE;
   BEGIN
      SELECT ctipo
        INTO vctipo
        FROM codparam
       WHERE cparam = pcparam;

      IF vctipo = 1
         AND ptvalpar IS NOT NULL
         AND pcvalpar IS NULL
         AND pfvalpar IS NULL
         AND psproduc IS NOT NULL THEN
         INSERT INTO parmotmov
                     (cmotmov, cparmot, tvalpar, sproduc)
              VALUES (pcmotmov, pcparam, ptvalpar, psproduc);
      ELSIF vctipo IN(2, 4)
            AND ptvalpar IS NULL
            AND pcvalpar IS NOT NULL
            AND pfvalpar IS NULL
            AND psproduc IS NOT NULL THEN
         INSERT INTO parmotmov
                     (cmotmov, cparmot, cvalpar, sproduc)
              VALUES (pcmotmov, pcparam, pcvalpar, psproduc);
      ELSIF vctipo = 3
            AND ptvalpar IS NULL
            AND pcvalpar IS NULL
            AND pfvalpar IS NOT NULL
            AND psproduc IS NOT NULL THEN
         INSERT INTO parmotmov
                     (cmotmov, cparmot, fvalpar, sproduc)
              VALUES (pcmotmov, pcparam, pfvalpar, psproduc);
      ELSE
         RETURN 108545;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         BEGIN
            IF vctipo = 1
               AND ptvalpar IS NOT NULL
               AND pcvalpar IS NULL
               AND pfvalpar IS NULL
               AND psproduc IS NOT NULL THEN
               UPDATE parmotmov
                  SET tvalpar = ptvalpar
                WHERE cmotmov = pcmotmov
                  AND cparmot = pcparam
                  AND sproduc = psproduc;
            ELSIF vctipo IN(2, 4)
                  AND ptvalpar IS NULL
                  AND pcvalpar IS NOT NULL
                  AND pfvalpar IS NULL
                  AND psproduc IS NOT NULL THEN
               UPDATE parmotmov
                  SET cvalpar = pcvalpar
                WHERE cmotmov = pcmotmov
                  AND cparmot = pcparam
                  AND sproduc = psproduc;
            ELSIF vctipo = 3
                  AND ptvalpar IS NULL
                  AND pcvalpar IS NULL
                  AND pfvalpar IS NOT NULL
                  AND psproduc IS NOT NULL THEN
               UPDATE parmotmov
                  SET fvalpar = pfvalpar
                WHERE cmotmov = pcmotmov
                  AND cparmot = pcparam
                  AND sproduc = psproduc;
            ELSE
               RETURN 108545;
            END IF;

            RETURN 0;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_mnt_param.f_ins_parmotmov', 1,
                           'when others pcparam =' || pcparam || ' pcmotmov=' || pcmotmov
                           || ' psproduc=' || psproduc,
                           SQLERRM);
               RETURN 108545;
         END;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_mnt_param.f_ins_parmotmov', 1,
                     'when others pcparam =' || pcparam || ' pcmotmov=' || pcmotmov
                     || ' psproduc=' || psproduc,
                     SQLERRM);
         RETURN 108545;
   END f_ins_parmotmov;
--Fi Bug 8789 - 18/02/2009 - AMC - Se crean las funciones para Parámetros Movimiento
END pac_mnt_param;

/

  GRANT EXECUTE ON "AXIS"."PAC_MNT_PARAM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MNT_PARAM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MNT_PARAM" TO "PROGRAMADORESCSI";
