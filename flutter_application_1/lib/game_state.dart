import 'dart:math';

import 'package:flutter/animation.dart';

class GameState {
  List<int> boardArr = [];

  GameState() {
    boardArr = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16];
  }


  int hover(int gestureDetectorIndex,  {int tileNum = -1}) {
    //handles tile movement logic
    int tile = tileNum == -1 ? boardArr[gestureDetectorIndex] : tileNum;
    return tile;
  }

  List<List<int>> tap(int gestureDetectorIndex,  {int tileNum = -1}) {
    //handles tile movement logic
    int tile = tileNum == -1 ? boardArr[gestureDetectorIndex] : tileNum;

    //return [[tile-1, 2, 1, 0, 1]];
    if(tile == 16) {
      //tap on empty tile
      return [];
    }

    int previousTile = tile;
    int currentTile = -1;
    List<List<int>> tmpAnimationList = [];
    List<int> tmpSwapList = [];

    //keep checking X axis until either hit 0 (empty tile) or out of bound, build animation list along the way
    do {
      //Check left
      currentTile = getTileLeft(previousTile);
      if (currentTile == -1) {
        break;
      } else {
        //Add to animation list
        int affectedTileIndex = findIndexOfTile(previousTile);
        int affectedTileRow = affectedTileIndex ~/ 4;
        int affectedTileColumn = affectedTileIndex % 4;
        tmpAnimationList = [...tmpAnimationList, [previousTile - 1 , affectedTileColumn-1, 0, 1, 1]];
        tmpSwapList = [previousTile, ...tmpSwapList];

        if(currentTile == 16) {
          for (int i = 0; i< tmpSwapList.length; i++) {
            swapPosition(tmpSwapList[i], 16);
          }
          return tmpAnimationList;
        }

        previousTile = currentTile;
      }
    } while (true);

    previousTile = tile;
    currentTile = -1;
    tmpAnimationList = [];
    tmpSwapList = [];

    do {
      //Check right
      currentTile = getTileRight(previousTile);
      if (currentTile == -1) {
        break;
      } else {
        //Add to animation list
        int affectedTileIndex = findIndexOfTile(previousTile);
        int affectedTileRow = affectedTileIndex ~/ 4;
        int affectedTileColumn = affectedTileIndex % 4;
        tmpAnimationList = [...tmpAnimationList, [previousTile - 1, affectedTileColumn+1, 0, 1, 1]];
        tmpSwapList = [previousTile, ...tmpSwapList];

        if(currentTile == 16) {
          for (int i = 0; i< tmpSwapList.length; i++) {
            swapPosition(tmpSwapList[i], 16);
          }
          return tmpAnimationList;
        }

        previousTile = currentTile;
      }
    } while (true);

    previousTile = tile;
    currentTile = -1;
    tmpAnimationList = [];
    tmpSwapList = [];

    //keep checking Y axis until either hit 0 (empty tile) or out of bound, build animation list along the way
    do {
      //Check left
      currentTile = getTileAbove(previousTile);
      if (currentTile == -1) {
        break;
      } else {
        //Add to animation list
        int affectedTileIndex = findIndexOfTile(previousTile);
        int affectedTileRow = affectedTileIndex ~/ 4;
        int affectedTileColumn = affectedTileIndex % 4;
        tmpAnimationList = [...tmpAnimationList, [previousTile - 1, affectedTileRow - 1, 1, 0, 1]];
        tmpSwapList = [previousTile, ...tmpSwapList];

        if(currentTile == 16) {
          for (int i = 0; i< tmpSwapList.length; i++) {
            swapPosition(tmpSwapList[i], 16);
          }
          return tmpAnimationList;
        }

        previousTile = currentTile;
      }
    } while (true);

    previousTile = tile;
    currentTile = -1;
    tmpAnimationList = [];
    tmpSwapList = [];

    do {
      //Check right
      currentTile = getTileBelow(previousTile);
      if (currentTile == -1) {
        break;
      } else {
        //Add to animation list
        int affectedTileIndex = findIndexOfTile(previousTile);
        int affectedTileRow = affectedTileIndex ~/ 4;
        int affectedTileColumn = affectedTileIndex % 4;
        tmpAnimationList = [...tmpAnimationList, [previousTile - 1, affectedTileRow + 1, 1, 0, 1]];
        tmpSwapList = [previousTile, ...tmpSwapList];

        if(currentTile == 16) {
          for (int i = 0; i< tmpSwapList.length; i++) {
            swapPosition(tmpSwapList[i], 16);
          }
          return tmpAnimationList;
        }

        previousTile = currentTile;
      }
    } while (true);

    //default case where tile is in an unmovable position
    return [];
  }

  List<List<List<int>>> shuffleBoard(int depth) {
    List<List<int>> animationListRow = [];
    List<List<int>> animationListCol = [];
    var rng = Random();
    for(int i = 0; i < depth; i++) {
      while (true) {
        int direction = rng.nextInt(4);
        int randomTileNum = -1;
        if(direction == 0) {
          randomTileNum = getTileAbove(16);
        } else if(direction == 1) {
          randomTileNum = getTileBelow(16);
        } else if(direction == 2) {
          randomTileNum = getTileLeft(16);
        } else if(direction == 3) {
          randomTileNum = getTileRight(16);
        }

        if(randomTileNum == -1) {
            continue;
        }
        tap(-1, tileNum: randomTileNum); 
        break;
      }
    }
    for (int i=0;i<boardArr.length-1;i++){
        int affectedTileIndex = findIndexOfTile(i+1);
        int affectedTileRow = affectedTileIndex ~/ 4;
        int affectedTileColumn = affectedTileIndex % 4;
        animationListRow.add([i, affectedTileRow, 1, 0, 1]); 
        animationListCol.add([i, affectedTileColumn, 0, 1, 1]); 
    }
    printBoard();
    return [animationListRow, animationListCol];
  }

  void printBoard() {
    String printString = "";
    for (int i = 0; i< boardArr.length; i++) {
      if(i != 0 && i%4 == 0) {
        printString += "\n";
      }
      printString += boardArr[i].toString() + "\t";
    }
    print(printString);
  }

  void swapPosition(int tile1, int tile2) {
    int tile1Index = findIndexOfTile(tile1);
    int tile2Index = findIndexOfTile(tile2);
    boardArr[tile2Index] = tile1;
    boardArr[tile1Index] = tile2;
  }

  int findIndexOfTile(int tile) {
    return boardArr.indexOf(tile);
  }

  int getTileAbove(int tile) {
    int tileIndex = findIndexOfTile(tile);
    if(tileIndex > 3) {
      return boardArr[tileIndex - 4];
    } else {
      return -1; //out of bound
    }
  }

  int getTileBelow(int tile) {
    int tileIndex = findIndexOfTile(tile);
    if(tileIndex <= 11) {
      return boardArr[tileIndex + 4];
    } else {
      return -1; //out of bound
    }
  }

  int getTileLeft(int tile) {
    int tileIndex = findIndexOfTile(tile);
    if(tileIndex % 4 != 0) {
      return boardArr[tileIndex - 1];
    } else {
      return -1; //out of bound
    }
  }

  int getTileRight(int tile) {
    int tileIndex = findIndexOfTile(tile);
    if(tileIndex % 4 != 3) {
      return boardArr[tileIndex + 1];
    } else {
      return -1; //out of bound
    }
  }
}