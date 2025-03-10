// Generated by CoffeeScript 1.12.6
(function() {
  this.GenreArtistsCrawler = (function() {
    function GenreArtistsCrawler(parentContext1, callbackFunction) {
      this.parentContext = parentContext1;
      this.callbackFunction = callbackFunction;
      console.log("Hello from the crawler side \n\n");
      this.genres = AppData.getAvailableGenres();
      this.currentGenreIndex = 0;
      this.currentGenre = this.genres[this.currentGenreIndex];
      this.singleGenreArtistsCrawler = new SingleGenreArtistsCrawler(this.currentGenre, this);
      this.singleGenreArtistsCrawler.crawl();
    }

    GenreArtistsCrawler.prototype.genreCrawlingDone = function(genre) {
      console.log("Done crawling genre " + genre + " \n\n");
      if (this.currentGenreIndex === this.genres.length - 1) {
        console.log("\n Finished crawling all genres");
        this.callbackFunction.call(this.parentContext);
        return;
      }
      this.currentGenre = this.genres[++this.currentGenreIndex];
      this.singleGenreArtistsCrawler = new SingleGenreArtistsCrawler(this.currentGenre, this);
      return this.singleGenreArtistsCrawler.crawl();
    };

    GenreArtistsCrawler.crawl = function(parentContext) {
      console.log("Crawl please");
      return this.genreArtistsCrawler = new GenreArtistsCrawler(parentContext);
    };

    return GenreArtistsCrawler;

  })();

  $(function() {
    return console.log("@GenreArtistsCrawler loaded");
  });

}).call(this);
