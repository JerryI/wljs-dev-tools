BeginPackage["JerryI`WolframJSFrontend`DevEvaluator`"];

Begin["Private`"];

DevProcessor[expr_String, signature_String, callback_] := Module[{str = StringDrop[expr, StringLength[First[StringSplit[expr, "\n"]]] ]},
  Print["DevProcessor!"];
  JerryI`WolframJSFrontend`Notebook`Notebooks[signature]["kernel"][InternalEvaluator[str, signature, "master"], callback, "Link"->"WSTP"];
];

DevQ[str_]      := Length[StringCases[StringSplit[str, "\n"] // First, RegularExpression["^\\.(master)$"]]] > 0;

JerryI`WolframJSFrontend`Notebook`NotebookAddEvaluator[(DevQ      ->  <|"SyntaxChecker"->(True&),               "Epilog"->(#&),             "Prolog"->(#&), "Evaluator"->DevProcessor       |>), "HighestPriority"];


InternalEvaluator[str_String, block_, signature_][callback_] := With[{$CellUid = CreateUUID[]},
  Block[{$NotebookID = signature, $evaluated, Global`$ignoreLongStrings = False},

      (* convert, and replace all frontend objects with its representations (except Set) and evaluate the result *)
      $evaluated = (ToExpression[str, InputForm, Hold] // ReleaseHold);

      (* blocks the output if the was a command from the procesor *)
      If[block === True, $evaluated = Null]; 

    (* replaces the output with a registered WebObjects/FrontEndObjects and releases created held frontend objects *)
    With[{$result = $evaluated},

      (* truncate the output, if it is too long and create a fake object to represent it *)
      With[{$string = StringReplace[ToString[$result, InputForm], {"\[NoBreak]"->"", "\[Pi]"->"$Pi$"}]},

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