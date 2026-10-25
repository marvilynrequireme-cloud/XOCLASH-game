
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

const bg = Color(0xFF101322);
const panel = Color(0xFF20253B);
const purple = Color(0xFF8B80F9);
const mint = Color(0xFF55D6BE);
const pink = Color(0xFFFF7892);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tic Tac Toe',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: purple,
          brightness: Brightness.dark,
        ),
      ),
      home: const MainMenu(),
    );
  }
}

// ================= MAIN MENU =================

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  void openGame(BuildContext context, bool ai) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GamePage(vsAI: ai),
      ),
    );
  }

  void showInfo(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.grid_3x3_rounded,
                    size: 85,
                    color: purple,
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'TIC TAC TOE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'The Ultimate X and O Challenge',
                    style: TextStyle(color: Colors.white60),
                  ),

                  const SizedBox(height: 55),

                  menuButton(
                    'PLAYER VS PLAYER',
                    Icons.people,
                    () => openGame(context, false),
                  ),

                  menuButton(
                    'PLAYER VS COMPUTER',
                    Icons.smart_toy,
                    () => openGame(context, true),
                  ),

                  menuButton(
                    'HOW TO PLAY',
                    Icons.help_outline,
                    () => showInfo(
                      context,
                      'How to Play',
                      '1. The game uses a 3x3 board.\n\n'
                      '2. Player X always moves first.\n\n'
                      '3. Players take turns placing X or O.\n\n'
                      '4. Get three matching symbols in a row, '
                      'column, or diagonal to win.\n\n'
                      '5. If the board is full without a winner, '
                      'the game ends in a draw.\n\n'
                      '6. In AI mode, you play X and the computer plays O.',
                    ),
                  ),

                  menuButton(
                    'ABOUT GAME',
                    Icons.info_outline,
                    () => showInfo(
                      context,
                      'About Tic Tac Toe',
                      'An academic mobile game developed using '
                      'Flutter and Dart.\n\n'
                      'Features:\n'
                      '- Two-player mode\n'
                      '- Computer opponent\n'
                      '- Minimax AI Algorithm\n'
                      '- Score tracking\n'
                      '- Winner detection\n\n'
                      'Developed for educational purposes.',
                    ),
                  ),

                  const SizedBox(height: 35),

                  const Text(
                    'ACADEMIC MOBILE GAME PROJECT',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget menuButton(
    String title,
    IconData icon,
    VoidCallback action,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton.icon(
          onPressed: action,
          icon: Icon(icon),
          label: Text(title),
          style: ElevatedButton.styleFrom(
            backgroundColor: panel,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: const BorderSide(color: purple),
            ),
          ),
        ),
      ),
    );
  }
}

// ================= GAME PAGE =================

class GamePage extends StatefulWidget {
  final bool vsAI;

  const GamePage({
    super.key,
    required this.vsAI,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<String> board = List.filled(9, '');

  String currentPlayer = 'X';
  String? winner;

  bool isDraw = false;
  bool aiThinking = false;

  int scoreX = 0;
  int scoreO = 0;
  int draws = 0;

  int roundId = 0;

  List<int> winningLine = [];

  final List<List<int>> combinations = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];

  // ============ WINNER CHECK ============

  String? checkWinner(List<String> b) {
    for (final line in combinations) {
      final a = line[0];
      final c = line[1];
      final d = line[2];

      if (b[a].isNotEmpty &&
          b[a] == b[c] &&
          b[c] == b[d]) {
        return b[a];
      }
    }

    return null;
  }

  void findWinningLine() {
    winningLine = [];

    for (final line in combinations) {
      if (board[line[0]].isNotEmpty &&
          board[line[0]] == board[line[1]] &&
          board[line[1]] == board[line[2]]) {
        winningLine = List.from(line);
        return;
      }
    }
  }

  // ============ PLAYER MOVE ============

  void playMove(int index) {
    if (board[index].isNotEmpty ||
        winner != null ||
        isDraw ||
        aiThinking) {
      return;
    }

    makeMove(index);

    if (widget.vsAI &&
        winner == null &&
        !isDraw &&
        currentPlayer == 'O') {
      aiMove();
    }
  }

  void makeMove(int index) {
    setState(() {
      board[index] = currentPlayer;

      winner = checkWinner(board);

      if (winner != null) {
        findWinningLine();

        if (winner == 'X') {
          scoreX++;
        } else {
          scoreO++;
        }
      } else if (!board.contains('')) {
        isDraw = true;
        draws++;
      } else {
        currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
      }
    });
  }

  // ============ MINIMAX AI ============

  int minimax(
    List<String> testBoard,
    bool maximizing,
    int depth,
  ) {
    final result = checkWinner(testBoard);

    if (result == 'O') return 10 - depth;
    if (result == 'X') return depth - 10;

    if (!testBoard.contains('')) return 0;

    if (maximizing) {
      int bestScore = -1000;

      for (int i = 0; i < 9; i++) {
        if (testBoard[i].isEmpty) {
          testBoard[i] = 'O';

          final score = minimax(
            testBoard,
            false,
            depth + 1,
          );

          testBoard[i] = '';

          bestScore = max(bestScore, score);
        }
      }

      return bestScore;
    } else {
      int bestScore = 1000;

      for (int i = 0; i < 9; i++) {
        if (testBoard[i].isEmpty) {
          testBoard[i] = 'X';

          final score = minimax(
            testBoard,
            true,
            depth + 1,
          );

          testBoard[i] = '';

          bestScore = min(bestScore, score);
        }
      }

      return bestScore;
    }
  }

  int getBestMove() {
    int bestScore = -1000;
    int bestMove = -1;

    final testBoard = List<String>.from(board);

    for (int i = 0; i < 9; i++) {
      if (testBoard[i].isEmpty) {
        testBoard[i] = 'O';

        final score = minimax(
          testBoard,
          false,
          0,
        );

        testBoard[i] = '';

        if (score > bestScore) {
          bestScore = score;
          bestMove = i;
        }
      }
    }

    return bestMove;
  }

  Future<void> aiMove() async {
    final savedRound = roundId;

    setState(() {
      aiThinking = true;
    });

    // Small delay for a natural computer response.
    await Future.delayed(
      const Duration(milliseconds: 450),
    );

    if (!mounted ||
        savedRound != roundId ||
        winner != null ||
        isDraw ||
        currentPlayer != 'O') {
      return;
    }

    final move = getBestMove();

    if (move != -1) {
      makeMove(move);
    }

    if (mounted) {
      setState(() {
        aiThinking = false;
      });
    }
  }

  // ============ RESET FUNCTIONS ============

  void resetGame() {
    setState(() {
      roundId++;
      board = List.filled(9, '');
      currentPlayer = 'X';
      winner = null;
      isDraw = false;
      aiThinking = false;
      winningLine = [];
    });
  }

  void resetScores() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset Scores?'),
        content: const Text(
          'This will clear all scores and restart the game.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              resetGame();

              setState(() {
                scoreX = 0;
                scoreO = 0;
                draws = 0;
              });
            },
            child: const Text('RESET'),
          ),
        ],
      ),
    );
  }

  // ============ GAME STATUS ============

  String get status {
    if (winner != null) {
      if (widget.vsAI) {
        return winner == 'X'
            ? '🎉 YOU WIN!'
            : '🤖 COMPUTER WINS!';
      }

      return '🎉 PLAYER $winner WINS!';
    }

    if (isDraw) return "IT'S A DRAW!";

    if (aiThinking) return 'COMPUTER IS THINKING...';

    if (widget.vsAI) {
      return currentPlayer == 'X'
          ? 'YOUR TURN (X)'
          : 'COMPUTER TURN (O)';
    }

    return "PLAYER $currentPlayer'S TURN";
  }

  // ============ UI ============

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bg,
        title: Text(
          widget.vsAI ? 'VS COMPUTER' : '2 PLAYERS',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            roundId++;
            Navigator.pop(context);
          },
        ),
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.grid_3x3_rounded,
                    color: purple,
                    size: 45,
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'TIC TAC TOE',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // SCOREBOARD
                  Row(
                    children: [
                      Expanded(
                        child: scoreCard(
                          widget.vsAI ? 'YOU (X)' : 'PLAYER X',
                          scoreX,
                          mint,
                          currentPlayer == 'X' &&
                              winner == null &&
                              !isDraw,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: scoreCard(
                          widget.vsAI ? 'AI (O)' : 'PLAYER O',
                          scoreO,
                          pink,
                          currentPlayer == 'O' &&
                              winner == null &&
                              !isDraw,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Text(
                    'DRAWS: $draws',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // GAME STATUS
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: panel,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      status,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // GAME BOARD
                  AspectRatio(
                    aspectRatio: 1,
                    child: GridView.builder(
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount: 9,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        final value = board[index];

                        final isWinning =
                            winningLine.contains(index);

                        return InkWell(
                          borderRadius: BorderRadius.circular(17),
                          onTap: () => playMove(index),
                          child: AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isWinning
                                  ? purple.withValues(alpha: 0.35)
                                  : panel,
                              borderRadius:
                                  BorderRadius.circular(17),
                              border: Border.all(
                                color: isWinning
                                    ? purple
                                    : value == 'X'
                                        ? mint
                                        : value == 'O'
                                            ? pink
                                            : const Color(0xFF343B57),
                                width: isWinning ? 3 : 2,
                              ),
                            ),
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    fontSize: 60,
                                    fontWeight: FontWeight.bold,
                                    color: value == 'X'
                                        ? mint
                                        : pink,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 25),

                  // PLAY AGAIN
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: resetGame,
                      icon: const Icon(Icons.refresh),
                      label: const Text('PLAY AGAIN'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextButton.icon(
                    onPressed: resetScores,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('RESET SCORES'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 5),

                  TextButton.icon(
                    onPressed: () {
                      roundId++;
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.home_outlined),
                    label: const Text('BACK TO MENU'),
                    style: TextButton.styleFrom(
                      foregroundColor: purple,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============ SCORE CARD ============

  Widget scoreCard(
    String title,
    int score,
    Color color,
    bool active,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active ? color : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '$score',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            active ? 'YOUR TURN' : 'PLAYER',
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}
