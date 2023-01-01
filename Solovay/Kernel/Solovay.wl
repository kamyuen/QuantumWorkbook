(* -*- mode:math -*- *)
Get["Q3`"];
Q3Assert["2.8.4"];

BeginPackage["Solovay`", {"Q3`"}]

Unprotect["`*"];
ClearAll["`*"];

`Solovay`$Version = StringJoin[
  "Solovay/", $Input, " v",
  StringSplit["$Revision: 1.10 $"][[2]], " (",
  StringSplit["$Date: 2022-12-31 00:45:49+09 $"][[2]], ") ",
  "Mahn-Soo Choi"
 ];

{ GroupCommutator,
  BalancedCommutator };

{ Solovay, TheSolovay, SolovayDagger };
{ SolovayChains,
  SolovayKitaev };

Begin["`Private`"]

GroupCommutator::usage = "GroupCommutator[a, b] returns the group commutator of a and b; that is, a**b**Inverse[a]**Inverse[b]."

GroupCommutator[a_?MatrixQ, b_?MatrixQ] :=
  Dot[a,  b, Topple @ a, Topple @ b]

GroupCommutator[a_?NonCommutativeQ, b_?NonCommutatorQ] :=
  Multiply[a, b, Dagger @ a, Dagger @ b]


BalancedCommutator::usage = "BalancedCommuator[u] returns the group commuator decomposition of 2 x 2 unitary matrix u; that is, a pair of two group elements a and b such that u = GroupCommutator[a, b]."

BalancedCommutator[mat_?SquareMatrixQ] := Module[
  {angle, axis, new, x, V, W, S},
  {angle, axis} = RotationSystem[mat];
  x = 2 * Sign[angle] * ArcSin[Sqrt @ Abs @ Sin[angle/4]];
  V = TheRotation[x, 3];
  W = TheRotation[x, 2];
  {angle, new} = RotationSystem[V . W . Topple[V] . Topple[W]];
  angle = ArcCos[new . axis];
  new = Cross[new, axis];
  S = TheRotation@{angle, new};
  {S . V . Topple[S], S . W . Topple[S]}
 ] /; Length[mat] == 2



SolovayKitaev::usage = "SolovayKitae[gg, u, n] returns a list of elementary generators from set gg that approximately reconstruct matrix u."

SolovayKitaev::init = "Generating the initial approximately covering set; it may take a while."

Options[SolovayKitaev] = {
  "InitialLength" -> 10
 }

$dictionary = {};

SolovayKitaev[u_?SquareMatrixQ, n_Integer] := Module[
  {uu, vv, ww,
   mu, mv, mw },
  {uu, mu} = SolovayKitaev[u, n-1];
  (* Echo[uu]; *)
  {mv, mw} = BalancedCommutator[u . Topple[mu]];
  (* Echo[MatrixForm /@ {vv, ww}]; *)
  {vv, mv} = SolovayKitaev[mv, n-1];
  {ww, mw} = SolovayKitaev[mw, n-1];
  { Join[vv, ww, Reverse[SolovayDagger @ vv], Reverse[SolovayDagger @ ww], uu],
    Dot[mv, mw, Topple @ mv, Topple @ mw, mu] }
 ]

SolovayKitaev[u_?SquareMatrixQ, 0] := Module[
  { kk },
  If[ $dictionary == {},
    PrintTemporary["Initializing the dictionary... It may take a while."];
    EchoTiming[$dictionary = svyDictionary[18]]
   ];
  kk = Keys @ MinimalBy[$dictionary, Norm[#-u]&];
  kk = Flatten @ MinimalBy[kk, Length, 1];
  {kk, $dictionary[kk]}
 ]


Solovay::usage = "Solovay[k] represents the element associated with index k in the densely generating set {H, T, \!\(\*SuperscriptBox[\(T\),\(-1\)]\)}."

SetAttributes[Solovay, Listable];

Format[Solovay[9]] = Interpretation["H", Pauli[6]];

Format[Solovay[k_Integer]] :=
  Interpretation[Superscript["T", ToString @ k], MultiplyPower[Pauli[8], k]]


TheSolovay::usage = "TheSolovay[k] returns the matrix representation of the element associated with index k in the densely generating set {H, T, \!\(\*SuperscriptBox[\(T\),\(-1\)]\)}."

SetAttributes[TheSolovay, Listable];

TheSolovay[9] = ThePauli[6];

TheSolovay[k_Integer] :=
  SparseArray[{{1, 1} -> 1, {2, 2} -> Exp[I*Pi*k/4]}, {2,2}]

TheSolovay @ Solovay[k_Integer] := TheSolovay[k]


SolovayDagger::usage = "SolovayDagger[k] returns the index corresponding to the Hermitian conjugate of Solovay[k]."

SetAttributes[SolovayDagger, Listable]

SolovayDagger[9] = 9;
SolovayDagger[k_Integer] = -k;


svyDictionary::usage = "..."

svyDictionary[n_Integer] := Module[
  { cc, mm },
  cc = Catenate @ SolovayChains @ Range[n];
  mm = Dot @@@ N[TheSolovay @ cc];
  AssociationThread[cc -> mm]
 ]


SolovayChains::usage = "..."

SetAttributes[SolovayChains, Listable];

SolovayChains[n_Integer] := Join[
  SolovayChains[n, 0],
  SolovayChains[n, 1],
  SolovayChains[n, 2]
 ]

SolovayChains[n_Integer, 0] := Module[
  { cc },
  cc = Catenate @ Table[IntegerPartitions[n+1-k, {k}, {1,2,3,4}], {k, 1, n}];
  cc = Catenate @ Map[
    Tuples,
    cc /. {1 -> {-1,1}, 2 -> {-2,2}, 3 -> {-3,3}, 4 -> {4}}
   ];
  Map[Riffle[#, 9]&, cc]
 ]

SolovayChains[n_Integer, 1] := With[
  { cc = SolovayChains[n-1, 0] },
  Join[Map[Prepend[#, 9]&, cc], Map[Append[#, 9]&, cc]]
 ]

SolovayChains[n_Integer, 2] := With[
  { cc = SolovayChains[n-2, 0] },
  Map[Join[{9}, #, {9}]&, cc]
 ]


End[]

SetAttributes[Evaluate @ Protect["`*"], ReadProtected];

EndPackage[]