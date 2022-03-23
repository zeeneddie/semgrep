(* Yoann Padioleau
 *
 * Copyright (C) 2021 r2c
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2.1 as published by the Free Software Foundation, with the
 * special exception on linking described in file license.txt.
 *
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the file
 * license.txt for more details.
 *)
open Common
open OCaml (* map_of_string, ... *)
open AST_generic
module G = AST_generic
module B = AST_generic_v1_t
module PI = Parse_info
module H = AST_generic_helpers

exception NoInterpolatedElement

(*****************************************************************************)
(* Prelude *)
(*****************************************************************************)
(* Convert the generic AST to the exported AST_generic_v1.atd type.
 *
 * This file is mostly a copy paste of Map_AST.ml, which itself
 * was mostly autogenerated by ocamltarzan.
 * alt: define a ppx deriving plugin to autogenerate the mapper
 * (or deriving map good enough?)
 *
 * I've tagged with 'new' recent AST_generic constructs not present
 * in AST_generic_v1.atd.
 *)

(*****************************************************************************)
(* Helpers *)
(*****************************************************************************)
let map_id x = x
let map_of_ref f x = f !x

let error any =
  let v = Meta_AST.vof_any any in
  let s = OCaml.string_of_v v in
  failwith (spf "TODO: %s" s)

(*****************************************************************************)
(* Mapper *)
(*****************************************************************************)

let map_token_location { PI.str; charpos; line; column; file } =
  { B.str; charpos; line; column; filename = file }

(* generated by ocamltarzan with: camlp4o -o /tmp/yyy.ml -I pa/ pa_type_conv.cmo pa_map.cmo  pr_o.cmo /tmp/xxx.ml  *)

let map_tok v : B.token =
  match v.PI.token with
  | PI.FakeTokStr (s, _) -> `FakeTok s
  | PI.OriginTok loc ->
      let loc = map_token_location loc in
      `OriginTok loc
  | _ -> error (Tk v)

let map_wrap _of_a (v1, v2) =
  let v1 = _of_a v1 and v2 = map_tok v2 in
  (v1, v2)

let map_bracket of_a (v1, v2, v3) =
  let v1 = map_tok v1 and v2 = of_a v2 and v3 = map_tok v3 in
  (v1, v2, v3)

let map_ident (v : ident) : B.ident = map_wrap map_of_string v
let map_dotted_ident v : B.dotted_ident = map_of_list map_ident v

let rec _map_qualifier = function
  | QDots _ -> failwith "TODO"
  | QExpr (e, t) ->
      let e = map_expr e in
      let t = map_tok t in
      `QExpr (e, t)

and map_module_name = function
  | FileName v1 ->
      let v1 = map_wrap map_of_string v1 in
      `FileName v1
  | DottedName v1 ->
      let v1 = map_dotted_ident v1 in
      `DottedName v1

and map_resolved_name (v1, v2) =
  let v1 = map_resolved_name_kind v1 in
  let v2 = map_of_int v2 in
  (v1, v2)

and map_resolved_name_kind = function
  | LocalVar -> `Local
  | Parameter -> `Param
  | EnclosedVar -> `EnclosedVar
  | Global -> `Global
  | ImportedEntity v1 ->
      let v1 = map_dotted_ident v1 in
      `ImportedEntity v1
  | ImportedModule v1 ->
      let v1 = map_module_name v1 in
      `ImportedModule v1
  | Macro -> `Macro
  | EnumConstant -> `EnumConstant
  | TypeName -> `TypeName
  | ResolvedName _v1 -> failwith "TODO"

and map_id_info x =
  match x with
  | {
   G.id_resolved = v_id_resolved;
   id_type = v_id_type;
   id_svalue = v3;
   id_hidden = _not_available_in_v1;
  } ->
      let v3 = map_of_ref (map_of_option map_svalue) v3 in
      let v_id_type = map_of_ref (map_of_option map_type_) v_id_type in
      let v_id_resolved =
        map_of_ref (map_of_option map_resolved_name) v_id_resolved
      in
      { B.id_resolved = v_id_resolved; id_type = v_id_type; id_constness = v3 }

and map_xml
    { G.xml_kind = v_xml_tag; xml_attrs = v_xml_attrs; xml_body = v_xml_body } :
    B.xml =
  let v_xml_body = map_of_list map_xml_body v_xml_body in
  let v_xml_attrs = map_of_list map_xml_attribute v_xml_attrs in
  let v_xml_tag = map_xml_kind v_xml_tag in
  { B.xml_kind = v_xml_tag; xml_attrs = v_xml_attrs; xml_body = v_xml_body }

and map_xml_kind = function
  | XmlClassic (v0, v1, v2, v3) ->
      let v0 = map_tok v0 in
      let v1 = map_ident v1 in
      let v2 = map_tok v2 in
      let v3 = map_tok v3 in
      `XmlClassic (v0, v1, v2, v3)
  | XmlSingleton (v0, v1, v2) ->
      let v0 = map_tok v0 in
      let v1 = map_ident v1 in
      let v2 = map_tok v2 in
      `XmlSingleton (v0, v1, v2)
  | XmlFragment (v1, v2) ->
      let v1 = map_tok v1 in
      let v2 = map_tok v2 in
      `XmlFragment (v1, v2)

and map_xml_attribute (x : G.xml_attribute) : B.xml_attribute =
  match x with
  | XmlAttr (v1, t, v2) ->
      let v1 = map_ident v1 and t = map_tok t and v2 = map_xml_attr v2 in
      `XmlAttr (v1, t, v2)
  | XmlAttrExpr v ->
      let v = map_bracket map_expr v in
      `XmlAttrExpr v
  | XmlEllipsis v ->
      let v = map_tok v in
      `XmlEllipsis v

and map_xml_attr v = map_expr v

and map_xml_body = function
  | XmlText v1 ->
      let v1 = map_wrap map_of_string v1 in
      `XmlText v1
  | XmlExpr v1 ->
      let v1 = map_bracket (map_of_option map_expr) v1 in
      `XmlExpr v1
  | XmlXml v1 ->
      let v1 = map_xml v1 in
      `XmlXml v1

and map_name = function
  | Id (v1, v2) ->
      let v1 = map_ident v1 and v2 = map_id_info v2 in
      `Id (v1, v2)
  | IdQualified _v1 -> failwith "TODO"

and map_expr x : B.expr =
  match x.e with
  | ParenExpr (_, e, _) -> map_expr e
  | N v1 ->
      let v1 = map_name v1 in
      `N v1
  | DotAccessEllipsis (v1, v2) ->
      let v1 = map_expr v1 in
      let v2 = map_tok v2 in
      `DotAccessEllipsis (v1, v2)
  | DisjExpr (v1, v2) ->
      let v1 = map_expr v1 in
      let v2 = map_expr v2 in
      `DisjExpr (v1, v2)
  | L v1 ->
      let v1 = map_literal v1 in
      `L v1
  | Container (v1, v2) ->
      let v1 = map_container_operator v1
      and v2 = map_bracket (map_of_list map_expr) v2 in
      `Container (v1, v2)
  | Comprehension (op, (l, (_eTODO, _xsTODO), r)) ->
      (* TODO *)
      let v1 = map_container_operator op in
      let l = map_tok l in
      let r = map_tok r in
      `Container (v1, (l, [], r))
  | Record v1 ->
      let v1 = map_bracket (map_of_list map_field) v1 in
      `Record v1
  | Constructor (v1, (_l, v2, _r)) ->
      let v1 = H.dotted_ident_of_name v1 in
      let v1 = map_dotted_ident v1 in
      let v2 = map_of_list map_expr v2 in
      `Constructor (v1, v2)
  | Lambda v1 ->
      let v1 = map_function_definition v1 in
      `Lambda v1
  | AnonClass v1 ->
      let v1 = map_class_definition v1 in
      `AnonClass v1
  | Xml v1 ->
      let v1 = map_xml v1 in
      `Xml v1
  | IdSpecial v1 ->
      let v1 = map_wrap map_special v1 in
      `IdSpecial v1
  | Call (v1, v2) ->
      let v1 = map_expr v1 and v2 = map_arguments v2 in
      `Call (v1, v2)
  | Assign (v1, v2, v3) ->
      let v1 = map_expr v1 and v2 = map_tok v2 and v3 = map_expr v3 in
      `Assign (v1, v2, v3)
  | AssignOp (v1, v2, v3) ->
      let v1 = map_expr v1
      and v2 = map_wrap map_arithmetic_operator v2
      and v3 = map_expr v3 in
      `AssignOp (v1, v2, v3)
  | LetPattern (v1, v2) ->
      let v1 = map_pattern v1 and v2 = map_expr v2 in
      `LetPattern (v1, v2)
  | DotAccess (v1, t, v2) ->
      let v1 = map_expr v1 and t = map_tok t and v2 = map_field_name v2 in
      `DotAccess (v1, t, v2)
  | ArrayAccess (v1, v2) ->
      let v1 = map_expr v1 and v2 = map_bracket map_expr v2 in
      `ArrayAccess (v1, v2)
  | SliceAccess (v1, v2) ->
      let f = map_of_option map_expr in
      let v1 = map_expr v1 and v2 = map_bracket (OCaml.map_of_all3 f f f) v2 in
      `SliceAccess (v1, v2)
  | Conditional (v1, v2, v3) ->
      let v1 = map_expr v1 and v2 = map_expr v2 and v3 = map_expr v3 in
      `Conditional (v1, v2, v3)
  | TypedMetavar (v1, v2, v3) ->
      let v1 = map_ident v1 and v2 = map_tok v2 and v3 = map_type_ v3 in
      `TypedMetavar (v1, v2, v3)
  | Yield (t, v1, v2) ->
      let t = map_tok t in
      let v1 = map_of_option map_expr v1 and v2 = map_of_bool v2 in
      `Yield (t, v1, v2)
  | Await (t, v1) ->
      let t = map_tok t in
      let v1 = map_expr v1 in
      `Await (t, v1)
  | Cast (v1, _t, v2) ->
      let v1 = map_type_ v1 and v2 = map_expr v2 in
      `Cast (v1, v2)
  | Seq v1 ->
      let v1 = map_of_list map_expr v1 in
      `Seq v1
  | Ref (t, v1) ->
      let t = map_tok t in
      let v1 = map_expr v1 in
      `Ref (t, v1)
  | DeRef (t, v1) ->
      let t = map_tok t in
      let v1 = map_expr v1 in
      `DeRef (t, v1)
  | Alias (_alias, _v1) -> failwith "TODO"
  | Ellipsis v1 ->
      let v1 = map_tok v1 in
      `Ellipsis v1
  | DeepEllipsis v1 ->
      let v1 = map_bracket map_expr v1 in
      `DeepEllipsis v1
  | OtherExpr (_v1, _v2) -> failwith "TODO"
  | StmtExpr _ -> failwith "TODO"

and map_field_name = function
  | FN v1 ->
      let v1 = map_name v1 in
      `EN v1
  | FDynamic v1 ->
      let v1 = map_expr v1 in
      `EDynamic v1

and map_entity_name = function
  | EN v1 ->
      let v1 = map_name v1 in
      `EN v1
  | EDynamic v1 ->
      let v1 = map_expr v1 in
      `EDynamic v1
  | EPattern _
  | OtherEntity _ ->
      failwith "TODO"

and map_literal = function
  | Unit v1 ->
      let v1 = map_tok v1 in
      `Unit v1
  | Bool v1 ->
      let v1 = map_wrap map_of_bool v1 in
      `Bool v1
  | Int v1 ->
      let v1 = map_wrap map_id v1 in
      `Int v1
  | Float v1 ->
      let v1 = map_wrap map_id v1 in
      `Float v1
  | Imag v1 ->
      let v1 = map_wrap map_of_string v1 in
      `Imag v1
  | Ratio v1 ->
      let v1 = map_wrap map_of_string v1 in
      `Ratio v1
  (* new: TODO: v0 skipped, should use PI.combine_info *)
  | Atom (_v0, v1) ->
      let v1 = map_wrap map_of_string v1 in
      `Atom v1
  | Char v1 ->
      let v1 = map_wrap map_of_string v1 in
      `Char v1
  | String v1 ->
      let v1 = map_wrap map_of_string v1 in
      `String v1
  (* new: TODO: lots of tokens skipped, should use PI.combine_info *)
  | Regexp ((_, v1, _), _) ->
      let v1 = map_wrap map_of_string v1 in
      `Regexp v1
  | Null v1 ->
      let v1 = map_tok v1 in
      `Null v1
  | Undefined v1 ->
      let v1 = map_tok v1 in
      `Undefined v1

and map_const_type = function
  | Cbool -> `Cbool
  | Cint -> `Cint
  | Cstr -> `Cstr
  | Cany -> `Cany

and map_svalue = function
  | Lit v1 ->
      let v1 = map_literal v1 in
      `Lit v1
  | Cst v1 ->
      let v1 = map_const_type v1 in
      `Cst v1
  | Sym _v1 -> (* Not supported by AST_generic_v1 *) `NotCst
  | NotCst -> `NotCst

and map_container_operator = function
  | Array -> `Array
  | List -> `List
  | Set -> `Set
  | Dict -> `Dict
  | Tuple -> `List

(* TODO `Tuple *)

(* TODO *)
and map_special x =
  match x with
  | ForOf -> `ForOf
  | Defined -> `Defined
  | This -> `This
  | Super -> `Super
  | Self -> `Self
  | Parent -> `Parent
  | Eval -> `Eval
  | Typeof -> `Typeof
  | Instanceof -> `Instanceof
  | Sizeof -> `Sizeof
  | New -> `New
  | Spread -> `Spread
  | HashSplat -> `HashSplat
  | NextArrayIndex -> `NextArrayIndex
  | Op v1 ->
      let v1 = map_arithmetic_operator v1 in
      `Op v1
  | EncodedString v1 ->
      let v1 = map_of_string v1 in
      `EncodedString v1
  | IncrDecr (v1, v2) ->
      let v1 = map_of_incdec v1 and v2 = map_of_prepost v2 in
      `IncrDecr (v1, v2)
  | ConcatString v1 ->
      let v1 = map_of_interpolated_kind v1 in
      `ConcatString v1
  | InterpolatedElement -> raise NoInterpolatedElement

and map_of_interpolated_kind = function
  | InterpolatedConcat -> `InterpolatedConcat
  | SequenceConcat -> `SequenceConcat
  | FString v1 -> `FString v1
  (* new: *)
  | TaggedTemplateLiteral -> `InterpolatedConcat

and map_of_incdec = function
  | Incr -> `Incr
  | Decr -> `Decr

and map_of_prepost = function
  | Prefix -> `Prefix
  | Postfix -> `Postfix

and map_arithmetic_operator = function
  | Plus -> `Plus
  | Minus -> `Minus
  | Mult -> `Mult
  | Div -> `Div
  | Mod -> `Mod
  | Pow -> `Pow
  | FloorDiv -> `FloorDiv
  | MatMult -> `MatMult
  | LSL -> `LSL
  | LSR -> `LSR
  | ASR -> `ASR
  | BitOr -> `BitOr
  | BitXor -> `BitXor
  | BitAnd -> `BitAnd
  | BitNot -> `BitNot
  | BitClear -> `BitClear
  | And -> `And
  | Or -> `Or
  | Xor -> `Xor (* new: *)
  | Pipe -> `Pipe
  | Not -> `Not
  | Eq -> `Eq
  | NotEq -> `NotEq
  | PhysEq -> `PhysEq
  | NotPhysEq -> `NotPhysEq
  | Lt -> `Lt
  | LtE -> `LtE
  | Gt -> `Gt
  | GtE -> `GtE
  | Cmp -> `Cmp
  | Concat -> `Concat
  | Append -> `Append
  | RegexpMatch -> `RegexpMatch
  | NotMatch -> `NotMatch
  | Range -> `Range
  | RangeInclusive -> `RangeInclusive
  | NotNullPostfix -> `NotNullPostfix
  | Length -> `Length
  | Elvis -> `Elvis
  | Nullish -> `Nullish
  | In -> `In
  | NotIn -> `NotIn
  | Is -> `Is
  | NotIs -> `NotIs (* new: *)
  | Background -> `Background

and map_arguments v = map_bracket (map_of_list map_argument) v

and map_argument = function
  | Arg v1 ->
      let v1 = map_expr v1 in
      `Arg v1
  | ArgType v1 ->
      let v1 = map_type_ v1 in
      `ArgType v1
  | ArgKwd (v1, v2) ->
      let v1 = map_ident v1 and v2 = map_expr v2 in
      `ArgKwd (v1, v2)
  | ArgKwdOptional (v1, v2) ->
      let v1 = map_ident v1 and v2 = map_expr v2 in
      (* new: *)
      `ArgKwdOptional (v1, v2)
  | OtherArg (v1, v2) ->
      let v1 = map_other_argument_operator v1 and v2 = map_of_list map_any v2 in
      `ArgOther (v1, v2)

and map_other_argument_operator _x = "TODO"

and map_type_ { t; t_attrs } =
  let tk = map_type_kind t in
  let _attrsTODO = map_of_list map_attribute t_attrs in
  tk

and map_type_kind = function
  | TyEllipsis v1 ->
      let v1 = map_tok v1 in
      `TyEllipsis v1
  | TyRecordAnon (v0, v1) ->
      let _v0 = map_wrap map_class_kind v0 in
      let _v1 = map_bracket (map_of_list map_field) v1 in
      failwith "TODO"
  | TyOr (v1, v2, v3) ->
      let v1 = map_type_ v1 in
      let v2 = map_tok v2 in
      let v3 = map_type_ v3 in
      `TyOr (v1, v2, v3)
  | TyAnd (v1, v2, v3) ->
      let v1 = map_type_ v1 in
      let v2 = map_tok v2 in
      let v3 = map_type_ v3 in
      `TyAnd (v1, v2, v3)
  | TyFun (v1, v2) ->
      let v1 = map_of_list map_parameter v1 and v2 = map_type_ v2 in
      `TyFun (v1, v2)
  (* new: TODO *)
  | TyApply (v1, v2) ->
      let v1 = map_type_ v1 and _v2TODO = map_type_arguments v2 in
      (* `TyNameApply ([], v2) *)
      v1
  | TyN v1 ->
      let v1 = map_name v1 in
      `TyN v1
  | TyVar v1 ->
      let v1 = map_ident v1 in
      `TyVar v1
  | TyAny v1 ->
      let v1 = map_tok v1 in
      `TyAny v1
  | TyArray (v1, v2) ->
      let v1 = map_bracket (map_of_option map_expr) v1 and v2 = map_type_ v2 in
      `TyArray (v1, v2)
  | TyPointer (t, v1) ->
      let t = map_tok t in
      let v1 = map_type_ v1 in
      `TyPointer (t, v1)
  | TyRef (t, v1) ->
      let t = map_tok t in
      let v1 = map_type_ v1 in
      `TyRef (t, v1)
  | TyTuple v1 ->
      let v1 = map_bracket (map_of_list map_type_) v1 in
      `TyTuple v1
  | TyQuestion (v1, t) ->
      let t = map_tok t in
      let v1 = map_type_ v1 in
      `TyQuestion (v1, t)
  | TyRest (t, v1) ->
      let v1 = map_type_ v1 in
      let t = map_tok t in
      `TyRest (t, v1)
  | TyExpr _v1 -> failwith "TODO"
  | OtherType (_v1, _v2) -> failwith "TODO"

(* new: brackets *)
and map_type_arguments (_, v, _) = map_of_list map_type_argument v

and map_type_argument = function
  | TA v1 ->
      let v1 = map_type_ v1 in
      `TypeArg v1
  | TAWildcard (v1, v2) ->
      let v1 = map_tok v1 in
      let v2 =
        map_of_option
          (fun (v1, v2) -> (map_wrap map_of_bool v1, map_type_ v2))
          v2
      in
      `TypeWildcard (v1, v2)
  | TAExpr _ -> failwith "TODO"
  | OtherTypeArg (v1, v2) ->
      let v1 = map_todo_kind v1 in
      let v2 = map_of_list map_any v2 in
      `OtherTypeArg (v1, v2)

and map_todo_kind _x = "TODO"

and map_attribute = function
  | KeywordAttr v1 -> (
      let v1 = map_wrap map_keyword_attribute v1 in
      match v1 with
      | Left v1, tok -> `KeywordAttr (v1, tok)
      | Right s, tok -> `OtherAttribute (s, [ `Tk tok ]))
  | NamedAttr (t, v1, v3) ->
      let t = map_tok t in
      let v1 = map_name v1 and v3 = map_bracket (map_of_list map_argument) v3 in
      `NamedAttr (t, v1, v3)
  | OtherAttribute (v1, v2) ->
      let v1 = map_other_attribute_operator v1
      and v2 = map_of_list map_any v2 in
      `OtherAttribute (v1, v2)

and map_keyword_attribute = function
  | Static -> Left `Static
  | Volatile -> Left `Volatile
  | Extern -> Left `Extern
  | Public -> Left `Public
  | Private -> Left `Private
  | Protected -> Left `Protected
  | Abstract -> Left `Abstract
  | Final -> Left `Final
  | Override -> Left `Override
  | Var -> Left `Var
  | Let -> Left `Let
  | Mutable -> Left `Mutable
  | Const -> Left `Const
  | Optional -> Left `Optional
  | NotNull -> Left `NotNull
  | Generator -> Left `Generator
  | Async -> Left `Async
  | Recursive -> Left `Recursive
  | MutuallyRecursive -> Left `MutuallyRecursive
  | Inline -> Left `Inline
  | Ctor -> Left `Ctor
  | Dtor -> Left `Dtor
  | Getter -> Left `Getter
  | Setter -> Left `Setter
  | Unsafe -> Left `Unsafe
  | DefaultImpl -> Left `DefaultImpl
  (* new: *)
  | Lazy -> Right "lazy"
  | RecordClass -> Right "RecordClass"
  | AnnotationClass -> Right "AnnotationClass"
  | EnumClass -> Right "EnumClass"
  | SealedClass -> Right "SealedClass"

and map_other_attribute_operator _x = "TODO"

and map_stmt x : B.stmt =
  let skind =
    match x.s with
    | DisjStmt (v1, v2) ->
        let v1 = map_stmt v1 in
        let v2 = map_stmt v2 in
        `DisjStmt (v1, v2)
    | ExprStmt (v1, t) ->
        let v1 = map_expr v1 in
        let t = map_tok t in
        `ExprStmt (v1, t)
    | DefStmt v1 ->
        let v1 = map_definition v1 in
        `DefStmt v1
    | DirectiveStmt v1 ->
        let v1 = map_directive v1 in
        `DirectiveStmt v1
    | Block v1 ->
        let v1 = map_bracket (map_of_list map_stmt) v1 in
        `Block v1
    | If (t, v1, v2, v3) ->
        let t = map_tok t in
        let v1 = map_condition v1
        and v2 = map_stmt v2
        and v3 = map_of_option map_stmt v3 in
        `If (t, v1, v2, v3)
    | While (t, v1, v2) ->
        let _t = map_tok t in
        let _v1 = map_condition v1 and _v2 = map_stmt v2 in
        failwith "TODO"
    | DoWhile (t, v1, v2) ->
        let t = map_tok t in
        let v1 = map_stmt v1 and v2 = map_expr v2 in
        `DoWhile (t, v1, v2)
    | For (t, v1, v2) ->
        let t = map_tok t in
        let v1 = map_for_header v1 and v2 = map_stmt v2 in
        `For (t, v1, v2)
    | Switch (v0, v1, v2) ->
        let v0 = map_tok v0 in
        let v1 = map_of_option map_condition v1
        and v2 = map_of_list map_case_and_body v2 in
        `Switch (v0, v1, v2)
    | Return (t, v1, sc) ->
        let t = map_tok t in
        let v1 = map_of_option map_expr v1 in
        let sc = map_tok sc in
        `Return (t, v1, sc)
    | Continue (t, v1, sc) ->
        let t = map_tok t in
        let v1 = map_label_ident v1 in
        let sc = map_tok sc in
        `Continue (t, v1, sc)
    | Break (t, v1, sc) ->
        let t = map_tok t in
        let v1 = map_label_ident v1 in
        let sc = map_tok sc in
        `Break (t, v1, sc)
    | Label (v1, v2) ->
        let v1 = map_label v1 and v2 = map_stmt v2 in
        `Label (v1, v2)
    | Goto (t, v1, _sc) ->
        let t = map_tok t in
        let v1 = map_label v1 in
        `Goto (t, v1)
    | Throw (t, v1, sc) ->
        let t = map_tok t in
        let v1 = map_expr v1 in
        let sc = map_tok sc in
        `Throw (t, v1, sc)
    | Try (t, v1, v2, v3) ->
        let t = map_tok t in
        let v1 = map_stmt v1
        and v2 = map_of_list map_catch v2
        and v3 = map_of_option map_finally v3 in
        `Try (t, v1, v2, v3)
    | WithUsingResource (t, v1, v2) ->
        let t = map_tok t in
        let v1 = map_stmt v1 in
        let v2 = map_stmt v2 in
        `WithUsingResource (t, v1, v2)
    | Assert (t, args, sc) ->
        let _t = map_tok t in
        let _args = map_arguments args in
        let _sc = map_tok sc in
        failwith "TODO"
        (* `Assert (t, v1, v2, sc) *)
    | OtherStmtWithStmt (v1, v2, v3) ->
        let _v1 = map_other_stmt_with_stmt_operator v1
        and _v2 = map_of_list map_any v2
        and _v3 = map_stmt v3 in
        (*`OtherStmtWithStmt (v1, v2, v3)*)
        failwith "TODO"
    | OtherStmt (v1, v2) ->
        let v1 = map_other_stmt_operator v1 and v2 = map_of_list map_any v2 in
        `OtherStmt (v1, v2)
  in
  { B.s = skind; s_id = x.s_id }

and map_condition _x = failwith "TODO"
and map_other_stmt_with_stmt_operator _x = "TODO"

and map_label_ident = function
  | LNone -> `LNone
  | LId v1 ->
      let v1 = map_label v1 in
      `LId v1
  | LInt v1 ->
      let v1 = map_wrap map_of_int v1 in
      `LInt v1
  | LDynamic v1 ->
      let v1 = map_expr v1 in
      `LDynamic v1

and map_case_and_body = function
  | CasesAndBody (v1, v2) ->
      let v1 = map_of_list map_case v1 and v2 = map_stmt v2 in
      `CasesAndBody (v1, v2)
  | CaseEllipsis v1 ->
      let v1 = map_tok v1 in
      `CaseEllipsis v1

and map_case = function
  | OtherCase _ -> failwith "TODO"
  | Case (t, v1) ->
      let t = map_tok t in
      let v1 = map_pattern v1 in
      `Case (t, v1)
  | CaseEqualExpr (t, v1) ->
      let t = map_tok t in
      let v1 = map_expr v1 in
      `CaseEqualExpr (t, v1)
  | Default t ->
      let t = map_tok t in
      `Default t

and map_catch (t, v1, v2) =
  let t = map_tok t in
  let v1 = map_catch_condition v1 and v2 = map_stmt v2 in
  (t, v1, v2)

and map_catch_condition = function
  | CatchPattern v1 ->
      let v1 = map_pattern v1 in
      v1
  | CatchParam p ->
      let _p = map_parameter_classic p in
      failwith "TODO"
  | OtherCatch _ -> failwith "TODO"

and map_finally v = map_tok_and_stmt v

and map_tok_and_stmt (t, v) =
  let t = map_tok t in
  let v = map_stmt v in
  (t, v)

and map_label v : B.label = map_ident v

and map_for_header = function
  | ForClassic (v1, v2, v3) ->
      let v1 = map_of_list map_for_var_or_expr v1
      and v2 = map_of_option map_expr v2
      and v3 = map_of_option map_expr v3 in
      `ForClassic (v1, v2, v3)
  | ForEach (v1, t, v2) ->
      let t = map_tok t in
      let v1 = map_pattern v1 and v2 = map_expr v2 in
      `ForEach (v1, t, v2)
  | ForEllipsis t ->
      let t = map_tok t in
      `ForEllipsis t
  | ForIn (v1, v2) ->
      let v1 = map_of_list map_for_var_or_expr v1
      and v2 = map_of_list map_expr v2 in
      `ForIn (v1, v2)

and map_for_var_or_expr = function
  | ForInitVar (v1, v2) ->
      let v1 = map_entity v1 and v2 = map_variable_definition v2 in
      `ForInitVar (v1, v2)
  | ForInitExpr v1 ->
      let v1 = map_expr v1 in
      `ForInitExpr v1

and map_other_stmt_operator _x = "TODO"

and map_pattern = function
  | PatEllipsis v1 ->
      let v1 = map_tok v1 in
      `PatEllipsis v1
  | PatRecord v1 ->
      let v1 =
        map_bracket
          (map_of_list (fun (v1, v2) ->
               let v1 = map_dotted_ident v1 and v2 = map_pattern v2 in
               (v1, v2)))
          v1
      in
      `PatRecord v1
  | PatId (v1, v2) ->
      let v1 = map_ident v1 and v2 = map_id_info v2 in
      `PatId (v1, v2)
  | PatLiteral v1 ->
      let v1 = map_literal v1 in
      `PatLiteral v1
  | PatType v1 ->
      let v1 = map_type_ v1 in
      `PatType v1
  | PatConstructor (v1, v2) ->
      let v1 = H.dotted_ident_of_name v1 in
      let v1 = map_dotted_ident v1 and v2 = map_of_list map_pattern v2 in
      `PatConstructor (v1, v2)
  | PatTuple v1 ->
      let v1 = map_bracket (map_of_list map_pattern) v1 in
      `PatTuple v1
  | PatList v1 ->
      let v1 = map_bracket (map_of_list map_pattern) v1 in
      `PatList v1
  | PatKeyVal (v1, v2) ->
      let v1 = map_pattern v1 and v2 = map_pattern v2 in
      `PatKeyVal (v1, v2)
  | PatUnderscore v1 ->
      let v1 = map_tok v1 in
      `PatUnderscore v1
  | PatDisj (v1, v2) ->
      let v1 = map_pattern v1 and v2 = map_pattern v2 in
      `PatDisj (v1, v2)
  | DisjPat (v1, v2) ->
      let v1 = map_pattern v1 and v2 = map_pattern v2 in
      `DisjPat (v1, v2)
  | PatTyped (v1, v2) ->
      let v1 = map_pattern v1 and v2 = map_type_ v2 in
      `PatTyped (v1, v2)
  | PatAs (v1, v2) ->
      let v1 = map_pattern v1
      and v2 =
        match v2 with
        | v1, v2 ->
            let v1 = map_ident v1 and v2 = map_id_info v2 in
            (v1, v2)
      in
      `PatAs (v1, v2)
  | PatWhen (v1, v2) ->
      let v1 = map_pattern v1 and v2 = map_expr v2 in
      `PatWhen (v1, v2)
  | OtherPat (v1, v2) ->
      let v1 = map_other_pattern_operator v1 and v2 = map_of_list map_any v2 in
      `OtherPat (v1, v2)

and map_other_pattern_operator _x = "TODO"

and map_definition (v1, v2) =
  let v1 = map_entity v1 and v2 = map_definition_kind v2 in
  (v1, v2)

and map_entity { G.name = v_name; attrs = v_attrs; tparams = v_tparams } =
  let v_tparams = map_of_list map_type_parameter v_tparams in
  let v_attrs = map_of_list map_attribute v_attrs in
  let v_name = map_entity_name v_name in
  { B.name = v_name; attrs = v_attrs; tparams = v_tparams }

and map_definition_kind = function
  | EnumEntryDef _v -> failwith "TODO"
  | FuncDef v1 ->
      let v1 = map_function_definition v1 in
      `FuncDef v1
  | VarDef v1 ->
      let v1 = map_variable_definition v1 in
      `VarDef v1
  | FieldDefColon v1 ->
      let v1 = map_variable_definition v1 in
      `FieldDefColon v1
  | ClassDef v1 ->
      let v1 = map_class_definition v1 in
      `ClassDef v1
  | TypeDef v1 ->
      let v1 = map_type_definition v1 in
      `TypeDef v1
  | ModuleDef v1 ->
      let v1 = map_module_definition v1 in
      `ModuleDef v1
  | MacroDef v1 ->
      let v1 = map_macro_definition v1 in
      `MacroDef v1
  | Signature v1 ->
      let v1 = map_type_ v1 in
      `Signature v1
  | UseOuterDecl v1 ->
      let v1 = map_tok v1 in
      `UseOuterDecl v1
  | OtherDef (v1, v2) ->
      let v1 = map_other_def_operator v1 in
      let v2 = map_of_list map_any v2 in
      `OtherDef (v1, v2)

and map_other_def_operator _x = "TODO"

and map_module_definition { G.mbody = v_mbody } =
  let v_mbody = map_module_definition_kind v_mbody in
  { B.mbody = v_mbody }

and map_module_definition_kind = function
  | ModuleAlias v1 ->
      let v1 = map_dotted_ident v1 in
      `ModuleAlias v1
  | ModuleStruct (v1, v2) ->
      let v1 = map_of_option map_dotted_ident v1
      and v2 = map_of_list map_item v2 in
      `ModuleStruct (v1, v2)
  | OtherModule (v1, v2) ->
      let v1 = map_other_module_operator v1 and v2 = map_of_list map_any v2 in
      `OtherModule (v1, v2)

and map_other_module_operator _x = "TODO"

and map_macro_definition
    { G.macroparams = v_macroparams; macrobody = v_macrobody } =
  let v_macrobody = map_of_list map_any v_macrobody in
  let v_macroparams = map_of_list map_ident v_macroparams in
  { B.macroparams = v_macroparams; macrobody = v_macrobody }

and map_type_parameter _tp = failwith "TODO"

(*
and _map_type_parameter_constraints v =
  map_of_list map_type_parameter_constraint v

and map_type_parameter_constraint = function
  | HasConstructor t ->
      let t = map_tok t in
      `HasConstructor t
  | OtherTypeParam (t, xs) ->
      let t = map_other_type_parameter_operator t in
      let xs = map_of_list map_any xs in
      `OtherTypeParam (t, xs)

and map_other_type_parameter_operator _x = "TODO"
*)
and map_function_kind = function
  | Function -> `Function
  | Method -> `Method
  | LambdaKind -> `LambdaKind
  | Arrow -> `Arrow
  (* new: *)
  | BlockCases -> `LambdaKind

and map_function_definition
    { G.fkind; fparams = v_fparams; frettype = v_frettype; fbody = v_fbody } =
  let fkind = map_wrap map_function_kind fkind in
  let v_fbody = map_function_body v_fbody in
  let v_frettype = map_of_option map_type_ v_frettype in
  let v_fparams = map_parameters v_fparams in
  { B.fkind; fparams = v_fparams; frettype = v_frettype; fbody = v_fbody }

and map_function_body x = map_stmt (H.funcbody_to_stmt x)
and map_parameters v = map_of_list map_parameter v

and map_parameter = function
  | Param v1 ->
      let v1 = map_parameter_classic v1 in
      `ParamClassic v1
  | ParamRest (v0, v1) ->
      let v0 = map_tok v0 in
      let v1 = map_parameter_classic v1 in
      `ParamRest (v0, v1)
  | ParamHashSplat (v0, v1) ->
      let v0 = map_tok v0 in
      let v1 = map_parameter_classic v1 in
      `ParamHashSplat (v0, v1)
  | ParamPattern v1 ->
      let v1 = map_pattern v1 in
      `ParamPattern v1
  | ParamEllipsis v1 ->
      let v1 = map_tok v1 in
      `ParamEllipsis v1
  | OtherParam (v1, v2) ->
      let _v1 = map_todo_kind v1 and _v2 = map_of_list map_any v2 in
      failwith "TODO"

and map_parameter_classic
    {
      G.pname = v_pname;
      pdefault = v_pdefault;
      ptype = v_ptype;
      pattrs = v_pattrs;
      pinfo = v_pinfo;
    } =
  let v_pinfo = map_id_info v_pinfo in
  let v_pattrs = map_of_list map_attribute v_pattrs in
  let v_ptype = map_of_option map_type_ v_ptype in
  let v_pdefault = map_of_option map_expr v_pdefault in
  let v_pname = map_of_option map_ident v_pname in
  {
    B.pname = v_pname;
    pdefault = v_pdefault;
    ptype = v_ptype;
    pattrs = v_pattrs;
    pinfo = v_pinfo;
  }

and map_variable_definition { G.vinit = v_vinit; vtype = v_vtype } =
  let v_vtype = map_of_option map_type_ v_vtype in
  let v_vinit = map_of_option map_expr v_vinit in
  { B.vinit = v_vinit; vtype = v_vtype }

and map_field = function
  | F v1 ->
      let v1 = map_stmt v1 in
      `FieldStmt v1

and map_type_definition { G.tbody = v_tbody } =
  let v_tbody = map_type_definition_kind v_tbody in
  { B.tbody = v_tbody }

and map_type_definition_kind = function
  | AbstractType _v1 -> failwith "TODO"
  | OrType v1 ->
      let v1 = map_of_list map_or_type_element v1 in
      `OrType v1
  | AndType v1 ->
      let v1 = map_bracket (map_of_list map_field) v1 in
      `AndType v1
  | AliasType v1 ->
      let v1 = map_type_ v1 in
      `AliasType v1
  | NewType v1 ->
      let v1 = map_type_ v1 in
      `NewType v1
  | Exception (v1, v2) ->
      let v1 = map_ident v1 and v2 = map_of_list map_type_ v2 in
      `Exception (v1, v2)
  | OtherTypeKind (v1, v2) ->
      let v1 = map_other_type_kind_operator v1
      and v2 = map_of_list map_any v2 in
      `OtherTypeKind (v1, v2)

and map_other_type_kind_operator _x = "TODO"

and map_or_type_element = function
  | OrConstructor (v1, v2) ->
      let v1 = map_ident v1 and v2 = map_of_list map_type_ v2 in
      `OrConstructor (v1, v2)
  | OrEnum (v1, v2) ->
      let v1 = map_ident v1 and v2 = map_of_option map_expr v2 in
      `OrEnum (v1, v2)
  | OrUnion (v1, v2) ->
      let v1 = map_ident v1 and v2 = map_type_ v2 in
      `OrUnion (v1, v2)

and map_class_definition
    {
      G.ckind = v_ckind;
      cextends = v_cextends;
      cimplements = v_cimplements;
      cbody = v_cbody;
      cmixins = v_cmixins;
      cparams = v_cparams;
    } =
  let v_cbody = map_bracket (map_of_list map_field) v_cbody in
  let v_cparams = map_parameters v_cparams in
  let v_cmixins = map_of_list map_type_ v_cmixins in
  let v_cimplements = map_of_list map_type_ v_cimplements in
  let v_cextends = map_of_list map_class_parent v_cextends in
  let v_ckind = map_wrap map_class_kind v_ckind in
  {
    B.ckind = v_ckind;
    cextends = v_cextends;
    cimplements = v_cimplements;
    cbody = v_cbody;
    cmixins = v_cmixins;
    cparams = v_cparams;
  }

and map_class_parent (_v1, _v2) = failwith "TODO"

and map_class_kind = function
  | Class -> `Class
  | Interface -> `Interface
  | Trait -> `Trait
  | Object -> `Object

and map_directive { d; d_attrs } =
  let d = map_directive_kind d in
  let _dattrsTODO = map_of_list map_attribute d_attrs in
  d

and map_directive_kind = function
  | ImportFrom (t, v1, v2, v3) ->
      let t = map_tok t in
      let v1 = map_module_name v1 and v2, v3 = map_alias (v2, v3) in
      `ImportFrom (t, v1, v2, v3)
  | ImportAs (t, v1, v2) ->
      let t = map_tok t in
      let v1 = map_module_name v1
      and v2 = map_of_option map_ident_and_id_info v2 in
      `ImportAs (t, v1, v2)
  | ImportAll (t, v1, v2) ->
      let t = map_tok t in
      let v1 = map_module_name v1 and v2 = map_tok v2 in
      `ImportAll (t, v1, v2)
  | Pragma (v1, v2) ->
      let v1 = map_ident v1 and v2 = map_of_list map_any v2 in
      `Pragma (v1, v2)
  | Package (t, v1) ->
      let t = map_tok t in
      let v1 = map_dotted_ident v1 in
      `Package (t, v1)
  | PackageEnd t ->
      let t = map_tok t in
      `PackageEnd t
  | OtherDirective (_v1, _v2) -> failwith "TODO"

and map_ident_and_id_info (v1, v2) =
  let v1 = map_ident v1 in
  let v2 = map_id_info v2 in
  (v1, v2)

and map_alias (v1, v2) =
  let v1 = map_ident v1 and v2 = map_of_option map_ident_and_id_info v2 in
  (v1, v2)

and map_item x = map_stmt x
and map_program v = map_of_list map_item v

and map_any x : B.any =
  match x with
  | Xmls _
  | ForOrIfComp _
  | Tp _
  | Ta _ ->
      failwith "TODO"
  | Cs _ -> failwith "TODO"
  | Ce _ -> failwith "TODO"
  | Anys _ -> error x
  | E v1 ->
      let v1 = map_expr v1 in
      `E v1
  | S v1 ->
      let v1 = map_stmt v1 in
      `S v1
  | Ss v1 ->
      let v1 = map_of_list map_stmt v1 in
      `Ss v1
  | Flds v1 ->
      let _v1 = map_of_list map_field v1 in
      (* TODO *)
      error x
  | T v1 ->
      let v1 = map_type_ v1 in
      `T v1
  | P v1 ->
      let v1 = map_pattern v1 in
      `P v1
  | At v1 ->
      let v1 = map_attribute v1 in
      `At v1
  | Fld v1 ->
      let v1 = map_field v1 in
      `Fld v1
  | Args v1 ->
      let v1 = map_of_list map_argument v1 in
      `Args v1
  | Params _ -> failwith "TODO"
  | I v1 ->
      let v1 = map_ident v1 in
      `I v1
  | Str v1 ->
      let v1 = map_wrap map_of_string v1 in
      `Str v1
  | Tk v1 ->
      let v1 = map_tok v1 in
      `Tk v1
  | TodoK v1 ->
      let v1 = map_ident v1 in
      `TodoK v1
  | Partial _v1 -> error x
  | Modn v1 ->
      let _v1 = map_module_name v1 in
      error x
  | ModDk v1 ->
      let _v1 = map_module_definition_kind v1 in
      error x
  | En v1 ->
      let _v1 = map_entity v1 in
      error x
  | Def v1 ->
      let _v1 = map_definition v1 in
      error x
  | Dir v1 ->
      let _v1 = map_directive v1 in
      error x
  | Di v1 ->
      let _v1 = map_dotted_ident v1 in
      error x
  | Pa v1 ->
      let _v1 = map_parameter v1 in
      error x
  | Ar v1 ->
      let _v1 = map_argument v1 in
      error x
  | Dk v1 ->
      let _v1 = map_definition_kind v1 in
      error x
  | Pr v1 ->
      let _v1 = map_program v1 in
      error x
  | Lbli v1 ->
      let _v1 = map_label_ident v1 in
      error x

(*****************************************************************************)
(* entry points *)
(*****************************************************************************)

let program x = map_program x