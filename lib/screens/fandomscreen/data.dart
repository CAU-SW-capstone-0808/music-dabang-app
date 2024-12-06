String fandomstate = '';
final List<String> fandomList = [
  '임영웅',
  '장윤정',
  '나훈아',
];

final List<Map<String, dynamic>> announcements = [
  {
    "title": "서울 콘서트 공지",
    "content": "2024년 12월 1일 서울에서 임영웅 콘서트가 열립니다. 많은 관심 부탁드립니다!",
    "date": "2024-12-01",
  },
  {
    "title": "임영웅 팬미팅 일정",
    "content": "팬미팅이 2024년 12월 10일에 부산에서 진행됩니다.",
    "date": "2024-12-10",
  },
  {
    "title": "임영웅 리사이틀",
    "content": "임영웅의 특별 리사이틀이 2024년 12월 27일에 개최됩니다.",
    "date": "2024-12-27",
  },
];

final List<Map<String, dynamic>> schedules = [
  {
    "date": "2024-11-20",
    "event": "임영웅 TV 출연",
  },
  {
    "date": "2024-11-25",
    "event": "임영웅 라디오 인터뷰",
  },
  {
    "date": "2024-12-01",
    "event": "서울 콘서트",
  },
  {
    "date": "2024-12-10",
    "event": "부산 팬미팅",
  },
];

final List<Map<String, dynamic>> news = [
  {
    "headline": "임영웅, 음악 방송 1위 기록",
    "details": "임영웅이 최신 앨범으로 음악 방송에서 1위를 차지했습니다. 축하 메시지가 이어지고 있습니다.",
    "date": "2024-11-15",
  },
  {
    "headline": "임영웅 팬미팅 예매 시작",
    "details": "임영웅의 팬미팅 예매가 시작되었습니다. 팬들의 관심이 뜨겁습니다!",
    "date": "2024-11-16",
  },
  {
    "headline": "임영웅, 새로운 CF 공개",
    "details": "임영웅이 새로운 CF에 등장했습니다. 따뜻한 이미지를 강조한 광고가 큰 화제를 모으고 있습니다.",
    "date": "2024-11-17",
  },
];

final List<Map<String, dynamic>> posts = [
  {
    "postId": 1,
    "title": "임영웅의 신곡 발표!",
    "content": "임영웅이 새 앨범을 발표했습니다. 감성적인 멜로디와 가사가 팬들의 마음을 사로잡네요!",
    "createdTime": "2024-11-01T10:00:00",
    "likes": 150,
    "comments": [
      {
        "postId": 2,
        "content": "노래가 너무 좋아요! 진짜 감동이에요.",
        "createdTime": "2024-11-01T10:15:00",
        "replies": [
          {
            "postId": 3,
            "content": "저도 하루 종일 반복 재생 중입니다!",
            "createdTime": "2024-11-01T10:20:00",
          },
          {
            "postId": 4,
            "content": "공감합니다. 최고예요!",
            "createdTime": "2024-11-01T10:25:00",
          },
        ],
      },
    ],
  },
  {
    "postId": 5,
    "title": "임영웅 콘서트 후기",
    "content": "임영웅 콘서트 다녀왔어요. 실물로 보니 더 멋지고 무대도 정말 감동적이었어요!",
    "createdTime": "2024-11-02T11:00:00",
    "likes": 200,
    "comments": [
      {
        "postId": 6,
        "content": "저도 갔는데 정말 최고였어요!",
        "createdTime": "2024-11-02T11:15:00",
        "replies": [],
      },
    ],
  },
  {
    "postId": 7,
    "title": "임영웅이 부른 인기 드라마 OST",
    "content": "임영웅의 OST가 드라마와 너무 잘 어울려요. 드라마가 끝나도 노래는 계속 듣게 될 것 같아요.",
    "createdTime": "2024-11-03T12:00:00",
    "likes": 180,
    "comments": [],
  },
  {
    "postId": 8,
    "title": "임영웅 팬클럽 활동 후기",
    "content": "팬클럽 모임에서 서로의 열정을 나눌 수 있어 정말 즐거웠어요. 다들 영웅시대 화이팅!",
    "createdTime": "2024-11-04T13:00:00",
    "likes": 170,
    "comments": [
      {
        "postId": 9,
        "content": "팬클럽 모임 정말 즐거웠어요. 다음에도 참여할게요!",
        "createdTime": "2024-11-04T13:15:00",
        "replies": [],
      },
    ],
  },
  {
    "postId": 10,
    "title": "임영웅의 뮤직비디오 촬영 비하인드",
    "content": "임영웅의 뮤직비디오 촬영 현장 모습이 공개되었습니다. 프로페셔널한 모습이 정말 인상적이에요.",
    "createdTime": "2024-11-05T14:00:00",
    "likes": 300,
    "comments": [
      {
        "postId": 11,
        "content": "비하인드 영상 보고 팬심이 더 커졌어요!",
        "createdTime": "2024-11-05T14:15:00",
        "replies": [
          {
            "postId": 12,
            "content": "동감합니다. 열심히 준비하는 모습이 멋져요!",
            "createdTime": "2024-11-05T14:20:00",
          },
        ],
      },
    ],
  },
  {
    "postId": 13,
    "title": "임영웅의 대표곡 추천",
    "content": "임영웅의 대표곡을 추천해주세요! 저는 '이제 나만 믿어요'가 가장 좋았어요.",
    "createdTime": "2024-11-06T15:00:00",
    "likes": 220,
    "comments": [],
  },
  {
    "postId": 14,
    "title": "임영웅 팬 아트 공유",
    "content": "팬분들이 만든 임영웅 팬 아트가 너무 멋져요. 영웅님이 보시면 정말 좋아할 것 같아요.",
    "createdTime": "2024-11-07T16:00:00",
    "likes": 180,
    "comments": [
      {
        "postId": 15,
        "content": "팬 아트 진짜 대단해요. 사랑이 느껴져요!",
        "createdTime": "2024-11-07T16:15:00",
        "replies": [],
      },
    ],
  },
  {
    "postId": 16,
    "title": "임영웅의 라디오 인터뷰",
    "content": "라디오에서 임영웅님 목소리 들으니 너무 반가웠어요. 인터뷰 내용도 감동적이었어요.",
    "createdTime": "2024-11-08T17:00:00",
    "likes": 190,
    "comments": [],
  },
  {
    "postId": 17,
    "title": "임영웅과 함께하는 여행 이벤트",
    "content": "팬들과 함께하는 특별한 여행 이벤트가 열립니다! 많은 참여 부탁드려요.",
    "createdTime": "2024-11-09T18:00:00",
    "likes": 210,
    "comments": [
      {
        "postId": 18,
        "content": "여행 이벤트 꼭 참여하고 싶어요!",
        "createdTime": "2024-11-09T18:15:00",
        "replies": [],
      },
    ],
  },
  {
    "postId": 19,
    "title": "임영웅이 추천하는 플레이리스트",
    "content": "임영웅님이 추천하는 곡들이 공개되었습니다. 한 곡 한 곡 모두 명곡이에요!",
    "createdTime": "2024-11-10T19:00:00",
    "likes": 250,
    "comments": [],
  },
];
