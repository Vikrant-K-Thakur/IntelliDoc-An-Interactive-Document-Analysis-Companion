from transformers import pipeline
import re
from typing import List, Dict

# Load models
qna_pipeline = pipeline("text2text-generation", model="valhalla/t5-base-qg-hl")
summarizer = pipeline("summarization", model="facebook/bart-large-cnn")

def split_into_topics(text: str) -> Dict[str, str]:
    """
    Split the text into topic-wise blocks.
    Assumes topics are introduced using numbered headings or capitalized titles.
    """
    topic_blocks = {}
    current_topic = "Introduction"
    current_text = []

    lines = text.splitlines()
    for line in lines:
        # Detect a new topic by pattern (e.g., "1. Topic Name" or ALL CAPS)
        if re.match(r"^\d+\.?\s+[A-Z][\w\s\-]{2,}", line) or line.isupper():
            if current_text:
                topic_blocks[current_topic] = "\n".join(current_text).strip()
            current_topic = line.strip()
            current_text = []
        else:
            current_text.append(line.strip())

    if current_text:
        topic_blocks[current_topic] = "\n".join(current_text).strip()

    return topic_blocks


def generate_flashcards(text: str) -> List[Dict[str, str]]:
    topics = split_into_topics(text)
    flashcards = []

    # Flashcard 1: Topic list
    topic_names = list(topics.keys())
    topic_list_card = {
        "question": "📚 What are the main topics covered?",
        "answer": "\n".join(f"- {name}" for name in topic_names)
    }
    flashcards.append(topic_list_card)

    # Flashcard 2-n: Short notes per topic
    for topic, topic_text in topics.items():
        try:
            summary = summarizer(topic_text, max_length=120, min_length=30, do_sample=False)[0]["summary_text"]
        except:
            summary = topic_text[:150] + "..."

        flashcards.append({
            "question": f"📝 What are the key points of '{topic}'?",
            "answer": summary
        })

    # Flashcard n+: Generate Q&A per topic
    for topic, topic_text in topics.items():
        sentences = re.split(r'(?<=[.!?]) +', topic_text)
        for sentence in sentences[:5]:  # Max 4–5 questions per topic
            if len(sentence.strip()) < 30:
                continue
            prompt = f"generate question: <hl> {sentence.strip()} <hl> {topic_text}"
            try:
                generated = qna_pipeline(prompt)[0]["generated_text"]
                flashcards.append({
                    "question": generated.strip(),
                    "answer": sentence.strip()
                })
            except:
                continue

    return flashcards
