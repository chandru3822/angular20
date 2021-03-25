package com.albatross.api.v1.company.blueraven.enums.tournament;


public enum TournamentPoolType {
    QUALIFYING(1L),
    LAST_CHANCE(2L),
    WINNER(3L);

    private Long id;

    TournamentPoolType(Long id) {
        this.id = id;
    }

    public Long getId() {
        return id;
    }
}
