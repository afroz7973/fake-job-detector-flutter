class AnalysisResult {
  final int scamScore;
  final String riskLevel;
  final List<String> reasons;

  AnalysisResult({
    required this.scamScore,
    required this.riskLevel,
    required this.reasons,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    final analysis = json['analysis'];
    return AnalysisResult(
      scamScore: analysis['scam_score'],
      riskLevel: analysis['risk_level'],
      reasons: List<String>.from(analysis['reasons']),
    );
  }
}
