BeginPackage["JerryI`WolframJSFrontend`DevEvaluator`", {"CodeParser`"}];


Begin["`Private`"];

SplitExpression[astr_] := With[{str = StringReplace[astr, {"%"->"Global`$out", "$Pi$"->"\[Pi]", ".master"->""}]},
  Select[Select[(StringTake[str, Partition[Join[{1}, #, {StringLength[str]}], 2]] &@
   Flatten[{#1 - 1, #2 + 1} & @@@ 
     Sort@
      Cases[
       CodeParser`CodeConcreteParse[str, 
         CodeParser`SourceConvention -> "SourceCharacterIndex"][[2]], 
       LeafNode[Token`Newline, _, a_] :> Lookup[a, Source, Nothing]]]), StringQ], (StringLength[#]>0) &]
];

WolframCheckSyntax[str_String] := 
    Module[{syntaxErrors = Cases[CodeParser`CodeParse[str],(ErrorNode|AbstractSyntaxErrorNode|UnterminatedGroupNode|UnterminatedCallNode)[___],Infinity]},
        If[Length[syntaxErrors]=!=0 ,
            

            Return[StringRiffle[
                TemplateApply["Syntax error `` at line `` column ``",
                    {ToString[#1],Sequence@@#3[CodeParser`Source][[1]]}
                ]&@@@syntaxErrors

            , "\n"], Module];
        ];
        Return[True, Module];
    ];

DevProcessor[expr_String, signature_String, callback_] := Module[{block= False, str = StringDrop[expr, StringLength[First[StringSplit[expr, "\n"]]] ]},
  Print["DevProcessor!"];
  If[StringTake[str, -1] === ";", block = True; str = StringDrop[str, -1]];
  InternalEvaluator[str, block, signature][callback];
];


DevQ[str_] := StringMatchQ[str, StartOfString ~~ ".master" ~~ __];


JerryI`WolframJSFrontend`Notebook`NotebookAddEvaluator[
  DevQ -> <|
    "SyntaxChecker"->(True&), 
    "Epilog"->SplitExpression, 
    "Prolog"->(#&), 
    "Evaluator"->DevProcessor
  |>, 
  "HighestPriority"
];


InternalEvaluator[str_String, block_, signature_][callback_] := With[{$CellUid = CreateUUID[]},
  Block[{$NotebookID = signature, $evaluated, Global`$ignoreLongStrings = False},

      (* convert, and replace all frontend objects with its representations (except Set) and evaluate the result *)
      $evaluated = (ToExpression[str, InputForm, Hold] // ReleaseHold);

      (* blocks the output if the was a command from the procesor *)
      If[block === True, $evaluated = Null]; 

    
    With[{$result = $evaluated},

     
      With[{$string = StringReplace[ToString[$result, InputForm], {"\[NoBreak]"->"", "\[Pi]"->"$Pi$"}]},
        Print["CALLBACK!"];
        Print[$string];
        callback[
          $string,

          (* used to track event of a cell *)
          $CellUid, 

          (* specify the frontened renderer *)
          "codemirror",

          (* an internal message for the master kernel, which passes the created objects during the evaluation *)
          (*JerryI`WolframJSFrontend`ExtendDefinitions[Global`$NewDefinitions]*)
          Null

        ];
      ]
    ];

    
  ]
];


End[];


EndPackage[];