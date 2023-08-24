use connect4_ai::{bitboard::BitBoard, opening_database::OpeningDatabase, solver::Solver};

fn main() {
    let mut input = String::new();
    std::io::stdin().read_line(&mut input).unwrap();
    let input = input.trim();
    let Ok(board) = BitBoard::from_moves(&input) else {
        std::process::exit(0);
    };
    let mut solver = Solver::new(board);
    let opening_database = OpeningDatabase::load();
    if let Ok(database) = opening_database {
        solver = solver.with_opening_database(database);
    }
    let (mut score, _) = solver.solve();
    let move_count = input.len();
    if move_count % 2 == 0 {
        score *= -1;
    }
    let size = 7 * 6;
    let mut x = (size - move_count) / 2;
    if x % 2 != 0 {
        x += 1;
    }
    let score = (score as f32) / (x as f32) / 2.0;
    let score = score + 0.5;

    println!("{}", (score * 100.0).clamp(0.0, 100.0) as i8)
}
