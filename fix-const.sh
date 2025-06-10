#!/bin/bash

echo "🔧 testファイルのconst修正中..."

# test/widgets/problem_card_test.dartのconst修正
sed -i 's/MaterialApp(/const MaterialApp(/g' test/widgets/problem_card_test.dart
sed -i 's/Scaffold(/const Scaffold(/g' test/widgets/problem_card_test.dart
sed -i 's/MathProblem(/const MathProblem(/g' test/widgets/problem_card_test.dart

echo "✅ const修正完了"
