import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shots/app/models/shot_card_model.dart';
import 'package:shots/app/providers/packs_provider.dart';
import 'package:shots/app/services/card_loading.dart';

class CardProvider extends ChangeNotifier {
  List<ShotCardModel> _cards = [];
  List<ShotCardModel> get cards => _cards;

  int _currentCardIndex = 0;
  int get currentCardIndex => _currentCardIndex;

  // number of cards to show behind current card
  int _nextCardsNo = 5;
  int get nextCardsNo => _nextCardsNo;

  // game started is to determine whether to re-load the cards
  bool _gameStarted = false;
  bool get gameStarted => _gameStarted;

  // cards gone through (for stats); this is not reset when cards are shuffled
  int _cardsGoneThrough = 0;
  int get cardsGoneThrough => _cardsGoneThrough;

  // cache of cards; used when user re-shuffles cards
  // if there was no _cardsCache, the YAML file will have to be loaded every time the user wants to re-shuff;e
  List<ShotCardModel> _cardsCache;

  // called on game start
  loadCards(BuildContext context) async {
    // load each pack and cards in respective packs
    final PacksProvider packsProvider = Provider.of<PacksProvider>(context, listen: false);
    _cards = await CardLoadingService.loadPacks(packsProvider.packs);

    // save a copy of the cards list for later
    _cardsCache = [..._cards];

    // randomize order
    shuffleCards();

    _gameStarted = true;
  }

  /// Adds all cards back to deck (including those discarded), and randomizes order.
  ///
  /// Set [shouldNotifyListeners] to [true] to rebuild UI
  shuffleCards({bool shouldNotifyListeners = false}) {
    // _cards.shuffle();
    _cards = [..._cardsCache]..shuffle();
    _currentCardIndex = 0;

    // only need to notify listeners when user re-shuffles
    if (shouldNotifyListeners) notifyListeners();
  }

  /// Called when a card is dragged away.
  nextCard() {
    // go to next card
    _currentCardIndex += 1;

    // add number to no of cards gone throgh
    _cardsGoneThrough += 1;

    notifyListeners();
  }

  /// Resets cards array, current card index, cards gone through, and sets game started to false
  endGame() {
    // clear cards (empty array)
    _currentCardIndex = 0;
    _cardsGoneThrough = 0;
    _cards = [];
    _gameStarted = false;
  }
}
